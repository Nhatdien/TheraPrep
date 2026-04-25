/**
 * Custom Template Store
 *
 * Manages the user's single custom daily journal template.
 * Offline-first: reads/writes SQLite locally, syncs to backend when online.
 */

import { defineStore } from 'pinia';
import TranquaraSDK from '../tranquara_sdk';
import CustomTemplateRepository from '~/services/sqlite/custom_template_repository';
import { useAuthStore } from './auth_store';
import type { SlideGroup } from '~/types/user_journal';

export interface CustomTemplateState {
  title: string;
  slideGroups: SlideGroup[];
  isLoaded: boolean;
}

export const useCustomTemplateStore = defineStore('custom_template', {
  state: (): CustomTemplateState => ({
    title: 'My Daily Template',
    slideGroups: [],
    isLoaded: false,
  }),

  getters: {
    hasTemplate: (state): boolean => state.slideGroups.length > 0,
  },

  actions: {
    /**
     * Load from SQLite. If online, also fetch the latest from the server
     * and upsert locally so both are in sync.
     */
    async loadCustomTemplate() {
      const authStore = useAuthStore();
      const userId = authStore.getUserUUID;
      if (!userId) return;

      try {
        // Try local first
        const local = await CustomTemplateRepository.get(userId);
        if (local) {
          this.title = local.title;
          this.slideGroups = JSON.parse(local.slide_groups) as SlideGroup[];
        }

        // Fetch from server to get the authoritative version
        const sdk = TranquaraSDK.getInstance();
        const remote = await sdk.getCustomTemplate();
        if (remote) {
          this.title = remote.title;
          this.slideGroups = remote.slide_groups;
          // Persist to SQLite
          await CustomTemplateRepository.save(
            userId,
            remote.title,
            JSON.stringify(remote.slide_groups)
          );
          await CustomTemplateRepository.markSynced(userId);
        }
      } catch (e) {
        // Network failure — local data is still available from above
        console.warn('[CustomTemplateStore] Failed to sync from server:', e);
      } finally {
        this.isLoaded = true;
      }
    },

    /**
     * Save locally and push to server. Best-effort — local is always updated.
     */
    async saveCustomTemplate(title: string, slideGroups: SlideGroup[]) {
      const authStore = useAuthStore();
      const userId = authStore.getUserUUID;
      if (!userId) return;

      this.title = title;
      this.slideGroups = slideGroups;

      const slideGroupsJson = JSON.stringify(slideGroups);

      // Always save locally first
      await CustomTemplateRepository.save(userId, title, slideGroupsJson);

      // Try to push to server
      try {
        const sdk = TranquaraSDK.getInstance();
        await sdk.upsertCustomTemplate({ title, slide_groups: slideGroups });
        await CustomTemplateRepository.markSynced(userId);
        console.log('[CustomTemplateStore] Template saved and synced');
      } catch (e) {
        console.warn('[CustomTemplateStore] Saved locally; sync failed (will retry later):', e);
      }
    },

    /** Clear local state (called on logout) */
    clear() {
      this.title = 'My Daily Template';
      this.slideGroups = [];
      this.isLoaded = false;
    },
  },
});
