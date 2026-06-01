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
      <h1 class="text-xl font-bold lg:text-2xl">{{ $t('profile.yourData') }}</h1>
    </div>

    <div class="space-y-6">
      <!-- Data & Sync -->
      <div class="space-y-4">
        <h2 class="text-sm font-semibold text-muted uppercase tracking-[0.2em] px-1">
          {{ $t('profile.dataSync') }}
        </h2>
        <SyncStatusDashboard
          :show-stats="true"
          :show-history="true"
          :show-actions="true"
        />
      </div>

      <!-- Data Management (Export, Delete Account) -->
      <SettingsDataManagementSection />
    </div>
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
  { label: t('profile.yourData') },
]);
</script>
