<template>
  <div class="min-h-screen flex items-center justify-center px-4">
    <UCard class="w-full max-w-md shadow-xl">
      <template #header>
        <h1 class="text-2xl font-semibold">{{ $t('forgotPassword.title') }}</h1>
        <p class="text-sm text-muted mt-1">{{ $t('forgotPassword.subtitle') }}</p>
      </template>

      <form class="space-y-4" @submit.prevent="onSubmit">
        <UFormField :label="$t('forgotPassword.email')" required>
          <UInput v-model="email" type="email" :placeholder="$t('forgotPassword.emailPlaceholder')" size="lg" />
        </UFormField>

        <UAlert
          v-if="success"
          color="success"
          variant="soft"
          :title="$t('forgotPassword.successMessage')"
        />

        <UAlert
          v-if="errorMessage"
          color="error"
          variant="soft"
          :title="errorMessage"
          @close="errorMessage = ''"
        />

        <UButton type="submit" block size="lg" :loading="isLoading" :disabled="!email">
          {{ $t('forgotPassword.sendResetLink') }}
        </UButton>
      </form>
    </UCard>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '~/stores/stores/auth_store';

definePageMeta({ layout: 'auth' });

const { t } = useI18n();
const authStore = useAuthStore();
const email = ref('');
const isLoading = ref(false);
const success = ref(false);
const errorMessage = ref('');

const onSubmit = async () => {
  isLoading.value = true;
  errorMessage.value = '';

  try {
    await authStore.requestPasswordReset(email.value.trim());
    success.value = true;
  } catch (error: any) {
    errorMessage.value = error.message || t('forgotPassword.errorDefault');
  } finally {
    isLoading.value = false;
  }
};
</script>
