<template>
  <div class="space-y-5">
    <div class="flex items-center gap-2 px-3 py-2 rounded-lg bg-amber-50 dark:bg-amber-900/20 border border-amber-200 dark:border-amber-800">
      <UIcon name="i-heroicons-information-circle" class="w-4 h-4 text-amber-500 shrink-0" />
      <p class="text-xs text-amber-700 dark:text-amber-300">Generic editor — slide type: <code class="font-mono font-semibold">{{ model.type }}</code></p>
    </div>

    <div :class="showVi ? 'grid grid-cols-2 gap-4' : ''" class="grid">
      <div class="space-y-1.5">
        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-200">Question / Title</label>
        <UInput v-model="model.question" placeholder="Question text" size="md" class="w-full" />
      </div>
      <div v-if="showVi" class="space-y-1.5">
        <label class="block text-sm font-semibold text-blue-500">Câu hỏi (VI)</label>
        <UInput v-model="model.question_vi" placeholder="Câu hỏi (VI)" size="md" class="w-full" />
      </div>
    </div>

    <div class="space-y-1.5">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
        Config <span class="text-xs text-gray-400">(JSON)</span>
      </label>
      <UTextarea
        :model-value="configJson"
        @update:model-value="updateConfig"
        :rows="6"
        size="md"
        class="w-full font-mono text-xs"
        placeholder="{}"
      />
      <p v-if="configError" class="text-xs text-red-500 flex items-center gap-1">
        <UIcon name="i-heroicons-exclamation-triangle" class="w-3.5 h-3.5" />
        {{ configError }}
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const configError = ref('');

const configJson = computed(() => {
  try {
    return JSON.stringify(model.value.config || {}, null, 2);
  } catch {
    return '{}';
  }
});

function updateConfig(value: string) {
  try {
    model.value.config = JSON.parse(value);
    configError.value = '';
  } catch {
    configError.value = 'Invalid JSON';
  }
}
</script>
