<template>
  <section class="px-4 py-6 pb-20 lg:pb-0">
    <DesktopBreadcrumb :items="breadcrumbs" />

    <div class="flex items-center gap-3 mb-6">
      <button
        class="text-muted hover:text-highlighted transition-colors lg:hidden"
        @click="$router.back()"
      >
        <ChevronLeft class="w-5 h-5" />
      </button>
      <h1 class="text-xl font-bold lg:text-2xl">{{ $t('profile.notifications') }}</h1>
    </div>

    <SettingsNotificationSection />
  </section>
</template>

<script setup lang="ts">
import type { BreadcrumbItem } from '@nuxt/ui';
import { ChevronLeft } from 'lucide-vue-next';
import DesktopBreadcrumb from '~/components/Common/DesktopBreadcrumb.vue';

definePageMeta({
  layout: 'detail',
});

const { t } = useI18n();

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  { label: t('nav.profile'), icon: 'i-lucide-user', to: '/profile' },
  { label: t('profile.notifications') },
]);
</script>
