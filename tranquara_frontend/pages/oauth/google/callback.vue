<template>
  <div class="min-h-screen flex items-center justify-center px-4">
    <UCard class="w-full max-w-md">
      <div class="py-6 text-center space-y-3">
        <Icon name="i-lucide-loader-2" class="w-8 h-8 animate-spin mx-auto text-primary" />
        <h1 class="text-xl font-semibold">Signing you in</h1>
        <p class="text-sm text-muted">Completing Google authentication...</p>
      </div>
    </UCard>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '~/stores/stores/auth_store';

definePageMeta({
  layout: 'auth',
});

const route = useRoute();
const authStore = useAuthStore();

onMounted(async () => {
  const oauthError = route.query.error as string | undefined;
  const oauthErrorDescription = route.query.error_description as string | undefined;

  if (oauthError) {
    const params = new URLSearchParams({
      oauth_error: oauthError,
      oauth_error_description: oauthErrorDescription || 'OAuth provider returned an error',
    });
    await navigateTo(`/login?${params.toString()}`, { replace: true });
    return;
  }

  const code = route.query.code as string | undefined;
  if (!code) {
    await navigateTo('/login?oauth_error=missing_code', { replace: true });
    return;
  }

  try {
    const redirectUri = `${window.location.origin}/oauth/google/callback`;
    await authStore.loginWithGoogleOAuthCode(code, redirectUri);
    await navigateTo('/', { replace: true });
  } catch (error: any) {
    const params = new URLSearchParams({
      oauth_error: 'exchange_failed',
      oauth_error_description: error?.message || 'Failed to exchange OAuth code',
    });
    await navigateTo(`/login?${params.toString()}`, { replace: true });
  }
});
</script>
