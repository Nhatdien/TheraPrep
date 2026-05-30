/**
 * Settings Store — Pinia
 *
 * Manages all user settings with local persistence via Capacitor Preferences.
 * Global settings (theme, AI, language) sync to backend via user_information.settings JSONB.
 * Device-specific settings (notifications) stay local only.
 *
 * Storage keys:
 *  - "settings_global"  → GlobalSettings JSON (local)
 *  - "settings_device"  → DeviceSettings JSON (local)
 *  - Backend source of truth: user_information.settings (cross-device sync)
 */

import { defineStore } from 'pinia';
import { storage } from '~/utils/storage';
import NotificationService from '~/services/notifications/notification_service';
import type {
  SettingsState,
  GlobalSettings,
  DeviceSettings,
  ThemeMode,
  FontSize,
  AppLocale,
  PersonalizationSettings,
  AIPrivacySettings,
  NotificationSettings,
} from '~/types/settings';
import {
  DEFAULT_GLOBAL_SETTINGS,
  DEFAULT_DEVICE_SETTINGS,
} from '~/types/settings';

const STORAGE_KEY_GLOBAL = 'settings_global';
const STORAGE_KEY_DEVICE = 'settings_device';

export const useSettingsStore = defineStore('settings', {
  state: (): SettingsState => ({
    global: structuredClone(DEFAULT_GLOBAL_SETTINGS),
    device: structuredClone(DEFAULT_DEVICE_SETTINGS),
    initialized: false,
    saving: false,
  }),

  getters: {
    // ─── Personalization ────────────────────────────────────────────────
    theme: (state): ThemeMode => state.global.personalization.theme,
    fontSize: (state): FontSize => state.global.personalization.font_size,
    reduceMotion: (state): boolean => state.global.personalization.reduce_motion,
    language: (state): AppLocale => state.global.personalization.language,

    // ─── AI & Privacy ───────────────────────────────────────────────────
    aiEnabled: (state): boolean => state.global.ai_privacy.ai_enabled,
    yourStory: (state): string => state.global.ai_privacy.your_story,
    dataCollection: (state): boolean => state.global.ai_privacy.data_collection,

    // ─── Notifications ──────────────────────────────────────────────────
    notifications: (state): NotificationSettings => state.device.notifications,

    // ─── Font size CSS class ────────────────────────────────────────────
    fontSizeClass: (state): string => {
      const map: Record<FontSize, string> = {
        small: 'text-sm',
        medium: 'text-base',
        large: 'text-lg',
      };
      return map[state.global.personalization.font_size];
    },
  },

  actions: {
    // ─── Initialization ─────────────────────────────────────────────────

    /**
     * Load settings from Capacitor Preferences and merge with backend.
     * Backend settings take priority (source of truth for cross-device sync).
     * Call this once during app initialization (plugin).
     */
    async loadSettings() {
      try {
        const [savedGlobal, savedDevice] = await Promise.all([
          storage.get<GlobalSettings>(STORAGE_KEY_GLOBAL),
          storage.get<DeviceSettings>(STORAGE_KEY_DEVICE),
        ]);

        if (savedGlobal) {
          // Deep merge with defaults so new fields get default values
          this.global = {
            personalization: {
              ...DEFAULT_GLOBAL_SETTINGS.personalization,
              ...savedGlobal.personalization,
            },
            ai_privacy: {
              ...DEFAULT_GLOBAL_SETTINGS.ai_privacy,
              ...savedGlobal.ai_privacy,
            },
          };
        }

        if (savedDevice) {
          this.device = {
            notifications: {
              ...DEFAULT_DEVICE_SETTINGS.notifications,
              ...savedDevice.notifications,
            },
          };
        }

        // Re-schedule any enabled reminders so they survive app restarts / device reboots
        await NotificationService.rehydrateFromSettings(this.device.notifications);

        this.initialized = true;
        console.log('[SettingsStore] Settings loaded from local storage');

        // Merge with backend settings (async, don't block initialization)
        await this._mergeSettingsFromBackend();
      } catch (error) {
        console.error('[SettingsStore] Failed to load settings:', error);
        this.initialized = true; // Use defaults on failure
      }
    },

    /**
     * Fetch settings from backend and merge into local state.
     * Backend settings take priority for cross-device consistency.
     */
    async _mergeSettingsFromBackend() {
      try {
        const sdk = await import('../tranquara_sdk').then(m => m.default.getInstance());
        if (!sdk.config.access_token) {
          return;
        }
        const response = await sdk.getUserInformation();
        const backendSettings = response?.user_info?.settings;
        if (!backendSettings) {
          console.log('[SettingsStore] No backend settings found, using local');
          return;
        }

        // Merge backend settings into local state (backend wins for global settings)
        const backendPersonalization = backendSettings.personalization;
        const backendAIPrivacy = backendSettings.ai_privacy;

        if (backendPersonalization) {
          this.global.personalization = {
            ...this.global.personalization,
            ...backendPersonalization,
          };
        }
        if (backendAIPrivacy) {
          this.global.ai_privacy = {
            ...this.global.ai_privacy,
            ...backendAIPrivacy,
          };
        }

        // Persist merged settings locally
        await this._saveGlobal();
        console.log('[SettingsStore] Merged settings from backend:', backendSettings);
      } catch (error) {
        console.warn('[SettingsStore] Failed to merge settings from backend:', error);
      }
    },

    // ─── Persistence Helpers ────────────────────────────────────────────

    async _saveGlobal() {
      this.saving = true;
      try {
        await storage.set(STORAGE_KEY_GLOBAL, this.global);
      } catch (error) {
        console.error('[SettingsStore] Failed to save global settings:', error);
      } finally {
        this.saving = false;
      }
    },

    async _saveDevice() {
      this.saving = true;
      try {
        await storage.set(STORAGE_KEY_DEVICE, this.device);
      } catch (error) {
        console.error('[SettingsStore] Failed to save device settings:', error);
      } finally {
        this.saving = false;
      }
    },

    // ─── Personalization Actions ────────────────────────────────────────

    async setTheme(theme: ThemeMode) {
      this.global.personalization.theme = theme;
      await this._saveGlobal();
    },

    async setFontSize(size: FontSize) {
      this.global.personalization.font_size = size;
      await this._saveGlobal();
    },

    async setReduceMotion(enabled: boolean) {
      this.global.personalization.reduce_motion = enabled;
      await this._saveGlobal();
    },

    async setLanguage(locale: AppLocale) {
      this.global.personalization.language = locale;
      await this._saveGlobal();
      // Sync settings to backend for AI memory generation
      this._syncSettingsToBackend().catch((err) => {
        console.warn('[SettingsStore] Failed to sync settings to backend:', err);
      });
    },

    /**
     * Sync global settings to backend user_information.settings.
     * This ensures AI-generated memories use the user's preferred language
     * and settings are consistent across devices.
     */
    async _syncSettingsToBackend() {
      try {
        const sdk = await import('../tranquara_sdk').then(m => m.default.getInstance());
        if (!sdk.config.access_token) {
          console.log('[SettingsStore] No access token, skipping settings sync');
          return;
        }
        await sdk.updateUserInformation({
          settings: {
            personalization: { ...this.global.personalization },
            ai_privacy: { ...this.global.ai_privacy },
          },
        });
        console.log('[SettingsStore] Settings synced to backend');
      } catch (error) {
        console.warn('[SettingsStore] Settings sync to backend failed:', error);
      }
    },

    // ─── AI & Privacy Actions ───────────────────────────────────────────

    async setAIEnabled(enabled: boolean) {
      this.global.ai_privacy.ai_enabled = enabled;
      await this._saveGlobal();
    },

    async setYourStory(story: string) {
      // Enforce 500 char limit
      this.global.ai_privacy.your_story = story.slice(0, 500);
      await this._saveGlobal();
    },

    async setDataCollection(enabled: boolean) {
      this.global.ai_privacy.data_collection = enabled;
      await this._saveGlobal();
    },

    // ─── Notification Actions ───────────────────────────────────────────

    async setMorningReminder(enabled: boolean, time?: string) {
      this.device.notifications.morning_enabled = enabled;
      if (time) this.device.notifications.morning_time = time;
      await this._saveDevice();
      // Wire up device notification
      if (enabled) {
        const granted = await NotificationService.requestPermission();
        if (granted) {
          await NotificationService.scheduleReminder('morning', this.device.notifications.morning_time);
        }
      } else {
        await NotificationService.cancelReminder('morning');
      }
    },

    async setEveningReminder(enabled: boolean, time?: string) {
      this.device.notifications.evening_enabled = enabled;
      if (time) this.device.notifications.evening_time = time;
      await this._saveDevice();
      // Wire up device notification
      if (enabled) {
        const granted = await NotificationService.requestPermission();
        if (granted) {
          await NotificationService.scheduleReminder('evening', this.device.notifications.evening_time);
        }
      } else {
        await NotificationService.cancelReminder('evening');
      }
    },

    // ─── Bulk Update ────────────────────────────────────────────────────

    async updatePersonalization(partial: Partial<PersonalizationSettings>) {
      this.global.personalization = { ...this.global.personalization, ...partial };
      await this._saveGlobal();
    },

    async updateAIPrivacy(partial: Partial<AIPrivacySettings>) {
      this.global.ai_privacy = { ...this.global.ai_privacy, ...partial };
      await this._saveGlobal();
    },

    // ─── Reset ──────────────────────────────────────────────────────────

    async resetAllSettings() {
      this.global = structuredClone(DEFAULT_GLOBAL_SETTINGS);
      this.device = structuredClone(DEFAULT_DEVICE_SETTINGS);
      await Promise.all([this._saveGlobal(), this._saveDevice()]);
      console.log('[SettingsStore] All settings reset to defaults');
    },

    /**
     * Clear all local settings data (used during account deletion / logout)
     */
    async clearLocalData() {
      await Promise.all([
        storage.remove(STORAGE_KEY_GLOBAL),
        storage.remove(STORAGE_KEY_DEVICE),
      ]);
      this.global = structuredClone(DEFAULT_GLOBAL_SETTINGS);
      this.device = structuredClone(DEFAULT_DEVICE_SETTINGS);
      this.initialized = false;
      console.log('[SettingsStore] Local settings data cleared');
    },
  },
});
