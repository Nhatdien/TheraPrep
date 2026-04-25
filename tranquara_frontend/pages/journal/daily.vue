<template>
  <JournalModalContents v-if="slideGroup" :template-id="''" :static-slide-group="slideGroup" :static-collection-title="templateStore.title" />
</template>

<script setup lang="ts">
import { useCustomTemplateStore } from '~/stores/stores/custom_template_store';
import type { SlideGroup } from '~/types/user_journal';

definePageMeta({ layout: 'default' });

const templateStore = useCustomTemplateStore();

// If no custom template, redirect to default Daily Reflection
if (!templateStore.hasTemplate) {
  const DAILY_REFLECTION_ID = '55555555-5555-5555-5555-555555555555';
  navigateTo(`/learn_and_prepare/collection/${DAILY_REFLECTION_ID}/morning-prep`, { replace: true });
}

const slideGroup = computed<SlideGroup | null>(() => {
  if (!templateStore.hasTemplate) return null;
  return templateStore.slideGroups[0] ?? null;
});
</script>
