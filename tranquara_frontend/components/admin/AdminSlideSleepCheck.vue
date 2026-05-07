<template>
  <div class="space-y-5">
    <div :class="showVi ? 'grid grid-cols-2 gap-4' : ''" class="grid">
      <div class="space-y-1.5">
        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-200">Question <span class="text-red-500">*</span></label>
        <UInput v-model="model.question" placeholder="How many hours did you sleep last night?" size="md" class="w-full" />
      </div>
      <div v-if="showVi" class="space-y-1.5">
        <label class="block text-sm font-semibold text-blue-500">Câu hỏi (VI)</label>
        <UInput v-model="model.question_vi" placeholder="Bạn ngủ bao nhiêu giờ?" size="md" class="w-full" />
      </div>
    </div>

    <div class="grid grid-cols-2 gap-4">
      <div class="space-y-1.5">
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Min hours</label>
        <UInput v-model.number="minVal" type="number" min="0" max="24" size="md" class="w-full" />
      </div>
      <div class="space-y-1.5">
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Max hours</label>
        <UInput v-model.number="maxVal" type="number" min="0" max="24" size="md" class="w-full" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const minVal = computed({
  get: () => model.value.config?.min ?? 0,
  set: (v) => { if (!model.value.config) model.value.config = {}; model.value.config.min = v; },
});
const maxVal = computed({
  get: () => model.value.config?.max ?? 12,
  set: (v) => { if (!model.value.config) model.value.config = {}; model.value.config.max = v; },
});
</script>
