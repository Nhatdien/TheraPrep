/**
 * Authentication Plugin
 * 
 * Initializes authentication state when the app starts
 * Sets up automatic token refresh based on token expiry time
 */

import { useAuthStore } from '~/stores/stores/auth_store';
import { useSettingsStore } from '~/stores/stores/settings_store';
import NotificationService from '~/services/notifications/notification_service';

export default defineNuxtPlugin(async (nuxtApp) => {
  const authStore = useAuthStore();
  const route = useRoute();

  // Don't initialize auth on login/register pages (they clear tokens on mount)
  const authPages = ['/login', '/register'];
  const isAuthPage = authPages.some(page => route.path.startsWith(page));

  if (!isAuthPage) {
    // Initialize auth state from stored tokens
    await authStore.initialize();
  }

  // Re-hydrate local notifications after app start (handles reinstall / device restart)
  if (import.meta.client && authStore.isAuthenticated) {
    const settingsStore = useSettingsStore();
    if (!settingsStore.initialized) {
      await settingsStore.loadSettings();
    }
    await NotificationService.rehydrateFromSettings(settingsStore.notifications);
  }

  // Set up proactive token refresh and session re-check on app resume.
  if (import.meta.client) {
    const runSessionCheck = async () => {
      if (authStore.isAuthenticated) {
        await authStore.getAccessToken();
      }
    };

    // Initial pass after plugin init to reduce first-request 401s.
    await runSessionCheck();

    const refreshInterval = setInterval(runSessionCheck, 30 * 1000);

    const onFocus = () => {
      runSessionCheck();
    };

    const onVisibilityChange = () => {
      if (document.visibilityState === 'visible') {
        runSessionCheck();
      }
    };

    window.addEventListener('focus', onFocus);
    document.addEventListener('visibilitychange', onVisibilityChange);

    nuxtApp.hook('app:beforeUnmount', () => {
      clearInterval(refreshInterval);
      window.removeEventListener('focus', onFocus);
      document.removeEventListener('visibilitychange', onVisibilityChange);
    });
  }

  console.log('Authentication initialized:', authStore.isAuthenticated);
});
