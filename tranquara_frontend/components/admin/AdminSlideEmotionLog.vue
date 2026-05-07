<template>
  <div class="space-y-5">
    <!-- Question -->
    <div :class="showVi ? 'grid grid-cols-2 gap-4' : 'grid-cols-1'" class="grid">
      <div class="space-y-1.5">
        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-200">
          Question <span class="text-red-500">*</span>
        </label>
        <UInput v-model="model.question" placeholder="How are you feeling right now?" size="md" class="w-full" />
      </div>
      <div v-if="showVi" class="space-y-1.5">
        <label class="block text-sm font-semibold text-blue-500">
          Câu hỏi (VI)
        </label>
        <UInput v-model="model.question_vi" placeholder="Bạn cảm thấy thế nào lúc này?" size="md" class="w-full" />
      </div>
    </div>

    <!-- Labels -->
    <div class="space-y-2">
      <div class="flex items-center justify-between">
        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-200">Scale Labels (1–10)</label>
        <button type="button" @click="resetDefaults" class="text-xs text-primary-500 hover:text-primary-600 font-medium">Reset defaults</button>
      </div>
      <div class="grid grid-cols-2 gap-2">
        <div v-for="(_, i) in 10" :key="i" class="flex items-center gap-2">
          <div class="flex items-center justify-center w-7 h-7 rounded-full text-xs font-bold shrink-0"
            :class="i < 3 ? 'bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400' : i < 5 ? 'bg-orange-100 dark:bg-orange-900/30 text-orange-600 dark:text-orange-400' : i < 7 ? 'bg-yellow-100 dark:bg-yellow-900/30 text-yellow-600 dark:text-yellow-400' : 'bg-green-100 dark:bg-green-900/30 text-green-600 dark:text-green-400'"
          >{{ i + 1 }}</div>
          <UInput
            :model-value="labels[i] || ''"
            @update:model-value="updateLabel(i, $event)"
            :placeholder="defaultLabels[i]"
            size="sm"
            class="w-full"
          />
        </div>
      </div>
      <p v-if="labels.filter(Boolean).length < 10" class="text-xs text-amber-500 flex items-center gap-1">
        <UIcon name="i-heroicons-exclamation-triangle" class="w-3.5 h-3.5" />
        {{ labels.filter(Boolean).length }}/10 labels filled
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const defaultLabels = [
  'Devastated', 'Very Sad', 'Sad', 'Low', 'Neutral',
  'Okay', 'Good', 'Very Good', 'Happy', 'Ecstatic',
];

const labels = computed(() => model.value.config?.labels || []);

function updateLabel(idx: number, value: string) {
  if (!model.value.config) model.value.config = { scale: '1-10', labels: [] };
  if (!model.value.config.labels) model.value.config.labels = [];
  while (model.value.config.labels.length < 10) model.value.config.labels.push('');
  model.value.config.labels[idx] = value;
}

function resetDefaults() {
  if (!model.value.config) model.value.config = { scale: '1-10' };
  model.value.config.labels = [...defaultLabels];
}

onMounted(() => {
  if (!model.value.config?.labels?.some(Boolean)) {
    resetDefaults();
  }
});
</script>
