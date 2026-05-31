<template>
  <UApp>
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </UApp>
</template>

<script setup lang="ts">
import { useSettingsStore } from "~/stores/stores/settings_store";
import type { FontSize } from "~/types/settings";
import { Capacitor } from '@capacitor/core';
import { App } from '@capacitor/app';
import { Browser } from '@capacitor/browser';

const config = useRuntimeConfig();
const settingsStore = useSettingsStore();

// ─── Apply font size to <html> element reactively ─────────────────────────
const fontSizeMap: Record<FontSize, string> = {
  small: 'app-font-small',
  medium: 'app-font-medium',
  large: 'app-font-large',
};

watch(
  () => settingsStore.fontSize,
  (newSize, oldSize) => {
    if (import.meta.client) {
      const html = document.documentElement;
      // Remove previous font size class
      if (oldSize) html.classList.remove(fontSizeMap[oldSize]);
      html.classList.add(fontSizeMap[newSize]);
    }
  },
  { immediate: true },
);

// ─── Apply reduce-motion preference reactively ───────────────────────────
watch(
  () => settingsStore.reduceMotion,
  (enabled) => {
    if (import.meta.client) {
      document.documentElement.classList.toggle('reduce-motion', enabled);
    }
  },
  { immediate: true },
);

onMounted(async () => {
  // await waitForToken();
  // userJournalStore().getAllTemplates();
  // userInfoStore.getMe();

  if (Capacitor.isNativePlatform()) {
    App.addListener('appUrlOpen', async ({ url }) => {
      if (url.includes('/oauth/google/callback')) {
        try {
          await Browser.close();
        } catch {
          // Browser may already be closed
        }
        const urlObj = new URL(url);
        await navigateTo(`/oauth/google/callback?${urlObj.searchParams.toString()}`, { replace: true });
      }
    });
  }
});
</script>
<style>
/* ─── Font Size Scaling ──────────────────────────────────────────────────── */
html.app-font-small {
  font-size: 14px;
}
html.app-font-medium {
  font-size: 16px;
}
html.app-font-large {
  font-size: 18px;
}

/* ─── Reduce Motion ──────────────────────────────────────────────────────── */
html.reduce-motion *,
html.reduce-motion *::before,
html.reduce-motion *::after {
  animation-duration: 0.01ms !important;
  animation-iteration-count: 1 !important;
  transition-duration: 0.01ms !important;
  scroll-behavior: auto !important;
}

.page-enter-active,
.page-leave-active {
  transition: opacity 0.25s ease;
}
.page-enter-from,
.page-leave-to {
  opacity: 0;
}

.layout-enter-active,
.layout-leave-active {
  transition: opacity 0.25s ease;
}
.layout-enter-from,
.layout-leave-to {
  opacity: 0;
}
</style>