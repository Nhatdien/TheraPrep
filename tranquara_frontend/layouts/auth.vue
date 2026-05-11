<template>
  <div class="min-h-screen flex items-center justify-center bg-default px-4 pt-[max(1rem,env(safe-area-inset-top))] pb-[max(1rem,env(safe-area-inset-bottom))]">
    <!-- Language Selector (top-right) -->
    <div class="fixed top-4 right-4 z-20">
      <USelectMenu
        v-model="currentLanguage"
        :items="localeOptions"
        value-key="value"
        class="w-32"
        size="xs"
        @update:model-value="onLocaleChange"
      />
    </div>

    <div class="w-full max-w-md flex flex-col">
      <!-- Brand mark -->
      <div class="flex flex-col items-center mb-8 gap-3">
        <BrandLogoMark :size="64" color="#F59E0B" variant="mark" />
        <span class="text-xl font-bold tracking-widest text-highlighted uppercase" style="letter-spacing:0.18em;">
          Theraprep
        </span>
        <p class="text-sm text-muted">{{ $t('authLayout.tagline') }}</p>
      </div>

      <!-- Page Content (login/register forms) -->
      <div class="shrink-0">
        <slot />
      </div>

      <!-- Terms & Privacy -->
      <div class="text-center mt-6 text-xs text-muted">
        {{ $t('authLayout.agreeContinue') }}
        <NuxtLink to="/terms" class="underline hover:text-default">{{ $t('authLayout.terms') }}</NuxtLink>
        {{ $t('authLayout.and') }}
        <NuxtLink to="/privacy" class="underline hover:text-default">{{ $t('authLayout.privacyPolicy') }}</NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useLanguage } from '~/composables/useLanguage';

const { currentLanguage, changeLanguage, availableLocales } = useLanguage();

const localeOptions = computed(() =>
  availableLocales.value.map((l) => ({
    label: l.name,
    value: l.code,
  })),
);

async function onLocaleChange(value: string) {
  await changeLanguage(value as 'en' | 'vi');
}
</script>
