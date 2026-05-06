<template>
  <div class="space-y-3">
    <div :class="showVi ? 'grid lg:grid-cols-2 gap-3' : ''">
      <UFormField label="Title">
        <UInput v-model="model.title" placeholder="Call to action title" size="sm" />
      </UFormField>
      <UFormField v-if="showVi" label="Title (VI)">
        <UInput v-model="model.title_vi" placeholder="Tiêu đề" size="sm" />
      </UFormField>
    </div>

    <UFormField label="Action *">
      <USelect v-model="action" :items="actionOptions" size="sm" />
    </UFormField>

    <UFormField label="Button Text">
      <UInput v-model="buttonText" placeholder="Start Exercise" size="sm" />
    </UFormField>
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
  set: (v) => {
    if (!model.value.config) model.value.config = {};
    model.value.config.action = v;
  },
});

const buttonText = computed({
  get: () => model.value.config?.buttonText || '',
  set: (v) => {
    if (!model.value.config) model.value.config = {};
    model.value.config.buttonText = v;
  },
});
</script>
