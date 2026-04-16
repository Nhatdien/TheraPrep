<template>
  <div>
    <!-- Login Card -->
    <UCard class="shadow-2xl">
      <template #header>
        <h2 class="text-2xl font-semibold text-highlighted">
          {{ $t('auth.welcomeBack') }}
        </h2>
        <p class="text-sm text-muted mt-1">
          {{ $t('auth.signInSubtitle') }}
        </p>
      </template>

      <div class="p-2">
        <!-- Error Message -->
        <UAlert
          v-if="errorMessage"
          color="error"
          variant="soft"
          icon="i-heroicons-exclamation-triangle"
          :title="errorMessage"
          class="mb-6"
          @close="errorMessage = ''"
        />

        <!-- Login Form -->
        <form @submit.prevent="handleLogin">
          <!-- Username/Email Field -->
          <UFormField :label="$t('auth.usernameOrEmail')" name="username" required class="w-full">
            <UInput
              v-model="username"
              type="text"
              :placeholder="$t('auth.enterUsername')"
              icon="i-heroicons-user"
              size="xl"
              :disabled="isLoading"
              required
              class="w-full text-base py-4"
            />
          </UFormField>

          <!-- Password Field -->
          <UFormField :label="$t('auth.password')" name="password" required class="w-full">
            <UInput
              v-model="password"
              :type="showPassword ? 'text' : 'password'"
              :placeholder="$t('auth.enterPassword')"
              icon="i-heroicons-lock-closed"
              size="xl"
              :disabled="isLoading"
              required
              class="w-full text-base py-4"
            >
              <template #trailing>
                <UButton
                  variant="ghost"
                  color="neutral"
                  size="xs"
                  :icon="showPassword ? 'i-heroicons-eye-slash' : 'i-heroicons-eye'"
                  @click="showPassword = !showPassword"
                />
              </template>
            </UInput>
          </UFormField>

          <!-- Remember Me & Forgot Password -->
          <div class="flex items-center justify-between pt-4">
            <UCheckbox v-model="rememberMe" :label="$t('auth.rememberMe')" />
            <NuxtLink
              to="/forgot-password"
              class="text-sm text-primary-600 hover:text-primary-700 dark:text-primary-400"
            >
              {{ $t('auth.forgotPassword') }}
            </NuxtLink>
          </div>

          <!-- Login Button -->
          <UButton
            type="submit"
            block
            size="xl"
            :loading="isLoading"
            :disabled="!username || !password"
            class="w-full mt-8 py-4 text-lg"
          >
            {{ $t('auth.signIn') }}
          </UButton>

          <UButton
            type="button"
            block
            size="xl"
            variant="outline"
            class="w-full mt-3 py-4 text-base"
            @click="handleGoogleLogin"
          >
            <template #leading>
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true">
                <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
                <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
              </svg>
            </template>
            Continue with Google
          </UButton>
        </form>
      </div>

      <template #footer>
        <!-- Divider -->
        <div class="relative my-6">
          <div class="absolute inset-0 flex items-center">
            <div class="w-full border-t"></div>
          </div>
          <div class="relative flex justify-center text-sm">
            <span class="px-2 bg-elevated text-muted">
              {{ $t('auth.dontHaveAccount') }}
            </span>
          </div>
        </div>

        <!-- Register Link -->
        <NuxtLink to="/register">
          <UButton variant="outline" block size="lg">
            {{ $t('auth.createAccount') }}
          </UButton>
        </NuxtLink>
      </template>
    </UCard>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '~/stores/stores/auth_store';

// Define page meta (use auth layout)
definePageMeta({
  layout: 'auth',
});

const authStore = useAuthStore();
const { t } = useI18n();

// Form state
const username = ref('');
const password = ref('');
const showPassword = ref(false);
const rememberMe = ref(false);
const isLoading = ref(false);
const errorMessage = ref('');

// Handle login
const handleLogin = async () => {
  isLoading.value = true;
  errorMessage.value = '';

  try {
    await authStore.login({
      username: username.value,
      password: password.value,
    });

    // Navigate to home page
    await navigateTo('/', { replace: true });
  } catch (error: any) {
    errorMessage.value = error.message || t('auth.loginFailed');
  } finally {
    isLoading.value = false;
  }
};

const handleGoogleLogin = async () => {
  const redirectUri = `${window.location.origin}/oauth/google/callback`;
  const oauthUrl = await authStore.getGoogleOAuthStartURL(redirectUri);
  window.location.href = oauthUrl;
};
</script>
