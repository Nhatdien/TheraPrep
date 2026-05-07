<template>
  <div class="space-y-3">
    <div :class="showVi ? 'grid lg:grid-cols-2 gap-3' : ''">
      <UFormField label="Question *">
        <UInput v-model="model.question" placeholder="How many hours did you sleep?" size="sm" />
      </UFormField>
      <UFormField v-if="showVi" label="Question (VI)">
        <UInput v-model="model.question_vi" placeholder="Bạn ngủ bao nhiêu giờ?" size="sm" />
      </UFormField>
    </div>

    <div class="grid grid-cols-2 gap-3">
      <UFormField label="Min hours">
        <UInput v-model.number="minVal" type="number" size="sm" />
      </UFormField>
      <UFormField label="Max hours">
        <UInput v-model.number="maxVal" type="number" size="sm" />
      </UFormField>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const minVal = computed({
  get: () => model.value.config?.min ?? 0,
  set: (v) => {
    if (!model.value.config) model.value.config = {};
    model.value.config.min = v;
  },
});

const maxVal = computed({
  get: () => model.value.config?.max ?? 12,
  set: (v) => {
    if (!model.value.config) model.value.config = {};
    model.value.config.max = v;
  },
});
</script>
