/**
 * useAIGuard — Composable for AI feature gating
 *
 * Checks whether AI features are enabled in settings AND whether the device
 * is online (AI requires server connectivity).
 * When disabled or offline, shows a toast message directing the user.
 * Also provides the user's "Your Story" context for AI requests.
 */

import { useSettingsStore } from '~/stores/stores/settings_store';
import NetworkMonitor from '~/services/sync/network_monitor';

export function useAIGuard() {
  const settingsStore = useSettingsStore();
  const toast = useToast();
  const { t } = useI18n();

  /** Whether AI features are currently enabled */
  const isAIEnabled = computed(() => settingsStore.aiEnabled);

  /** Whether the device is online */
  const isOnline = computed(() => NetworkMonitor.isConnected());

  /** The user's personal story context (empty string if none) */
  const yourStory = computed(() => settingsStore.yourStory);

  /**
   * Check if AI is enabled AND device is online. 
   * If not, show a toast and return false.
   * Use this as a guard before any AI call:
   *
   * ```ts
   * const { canUseAI, yourStory } = useAIGuard();
   * if (!canUseAI()) return;
   * ```
   */
  const canUseAI = (): boolean => {
    if (!settingsStore.aiEnabled) {
      toast.add({
        title: t('aiGuard.disabledTitle'),
        description: t('aiGuard.disabledDesc'),
        icon: 'i-lucide-sparkles',
        color: 'warning',
      });
      return false;
    }

    if (!NetworkMonitor.isConnected()) {
      toast.add({
        title: t('aiGuard.offlineTitle'),
        description: t('aiGuard.offlineDesc'),
        icon: 'i-lucide-wifi-off',
        color: 'info',
      });
      return false;
    }

    return true;
  };

  return {
    isAIEnabled,
    isOnline,
    yourStory,
    canUseAI,
  };
}
