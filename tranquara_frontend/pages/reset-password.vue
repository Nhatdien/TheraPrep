<template>
  <div class="min-h-screen flex items-center justify-center px-4">
    <UCard class="w-full max-w-md shadow-xl">
      <template #header>
        <h1 class="text-2xl font-semibold">Set a new password</h1>
        <p class="text-sm text-muted mt-1">Use the token from your reset email.</p>
      </template>

      <form class="space-y-4" @submit.prevent="onSubmit">
        <UFormField label="Reset token" required>
          <UInput v-model="token" type="text" size="lg" placeholder="Paste token" />
        </UFormField>

        <UFormField label="New password" required>
          <UInput v-model="newPassword" type="password" size="lg" placeholder="••••••••" />
        </UFormField>

        <UFormField label="Confirm password" required>
          <UInput v-model="confirmPassword" type="password" size="lg" placeholder="••••••••" />
        </UFormField>

        <UAlert
          v-if="success"
          color="success"
          variant="soft"
          title="Password updated. You can now sign in."
        />

        <UAlert
          v-if="errorMessage"
          color="error"
          variant="soft"
          :title="errorMessage"
          @close="errorMessage = ''"
        />

        <UButton
          type="submit"
          block
          size="lg"
          :loading="isLoading"
          :disabled="!token || !newPassword || !confirmPassword"
        >
          Update password
        </UButton>
      </form>
    </UCard>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '~/stores/stores/auth_store';

definePageMeta({ layout: 'auth' });

const authStore = useAuthStore();
const token = ref('');
const newPassword = ref('');
const confirmPassword = ref('');
const isLoading = ref(false);
const success = ref(false);
const errorMessage = ref('');

onMounted(() => {
  const route = useRoute();
  const tokenFromQuery = route.query.token as string | undefined;
  if (tokenFromQuery) {
    token.value = tokenFromQuery;
  }
});

const onSubmit = async () => {
  isLoading.value = true;
  errorMessage.value = '';

  if (newPassword.value !== confirmPassword.value) {
    errorMessage.value = 'Passwords do not match.';
    isLoading.value = false;
    return;
  }

  try {
    await authStore.resetPassword(token.value.trim(), newPassword.value, confirmPassword.value);
    success.value = true;
  } catch (error: any) {
    errorMessage.value = error.message || 'Unable to reset password.';
  } finally {
    isLoading.value = false;
  }
};
</script>
