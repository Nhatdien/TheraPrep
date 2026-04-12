/**
 * Authentication Plugin
 * 
 * Initializes authentication state when the app starts
 * Sets up automatic token refresh based on token expiry time
 */

import { useAuthStore } from '~/stores/stores/auth_store';

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
