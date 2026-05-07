<template>
  <div class="space-y-5">
    <!-- Title -->
    <div :class="showVi ? 'grid grid-cols-2 gap-4' : ''" class="grid">
      <div class="space-y-1.5">
        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-200">Title</label>
        <UInput v-model="model.title" placeholder="Ready to try a breathing exercise?" size="md" class="w-full" />
      </div>
      <div v-if="showVi" class="space-y-1.5">
        <label class="block text-sm font-semibold text-blue-500">Tiêu đề (VI)</label>
        <UInput v-model="model.title_vi" placeholder="Tiêu đề" size="md" class="w-full" />
      </div>
    </div>

    <!-- Action + Button -->
    <div class="grid grid-cols-2 gap-4">
      <div class="space-y-1.5">
        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-200">Action <span class="text-red-500">*</span></label>
        <USelect v-model="action" :items="actionOptions" size="md" class="w-full" />
      </div>
      <div class="space-y-1.5">
        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-200">Button Text</label>
        <UInput v-model="buttonText" placeholder="Start Exercise" size="md" class="w-full" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const actionOptions = [
  { label: 'Breathing Exercise', value: 'breathing_exercise' },
  { label: 'Emotion Check-in', value: 'emotion_check' },
  { label: 'Mindfulness Pause', value: 'mindfulness_pause' },
  { label: 'Custom', value: 'custom' },
];

const action = computed({
  get: () => model.value.config?.action || 'breathing_exercise',
  set: (v) => { if (!model.value.config) model.value.config = {}; model.value.config.action = v; },
});
const buttonText = computed({
  get: () => model.value.config?.buttonText || '',
  set: (v) => { if (!model.value.config) model.value.config = {}; model.value.config.buttonText = v; },
});
</script>
