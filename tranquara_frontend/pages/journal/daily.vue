<template>
  <div v-if="!templateStore.isLoaded" class="flex items-center justify-center min-h-screen">
    <div class="w-8 h-8 border-2 border-primary border-t-transparent rounded-full animate-spin" />
  </div>
  <JournalModalContents
    v-else-if="slideGroup"
    :static-slide-group="slideGroup"
    :static-collection-title="templateStore.title"
  />
</template>

<script setup lang="ts">
import { useCustomTemplateStore } from '~/stores/stores/custom_template_store';
import type { SlideGroup } from '~/types/user_journal';

definePageMeta({ layout: 'detail' });

const templateStore = useCustomTemplateStore();

// Wait for template to load, then redirect if none exists
const DAILY_REFLECTION_ID = '55555555-5555-5555-5555-555555555555';

// Mirror the same time logic as DailyCheckIn: 0–16h → morning-prep, 17h+ → evening-reflection
const activeSlideGroup = new Date().getHours() >= 17 ? 'evening-reflection' : 'morning-prep';

onMounted(async () => {
  if (!templateStore.isLoaded) {
    await templateStore.loadCustomTemplate();
  }
  if (!templateStore.hasTemplate) {
    navigateTo(`/learn_and_prepare/collection/${DAILY_REFLECTION_ID}/${activeSlideGroup}`, { replace: true });
  }
});

const slideGroup = computed<SlideGroup | null>(() => {
  if (!templateStore.hasTemplate) return null;
  return templateStore.slideGroups[0] ?? null;
});
</script>
