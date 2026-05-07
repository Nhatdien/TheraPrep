<template>
  <div class="space-y-5">
    <!-- Question -->
    <div :class="showVi ? 'grid grid-cols-2 gap-4' : ''" class="grid">
      <div class="space-y-1.5">
        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-200">Question <span class="text-red-500">*</span></label>
        <UTextarea v-model="model.question" placeholder="What would you like to ask?" :rows="2" size="md" class="w-full" />
      </div>
      <div v-if="showVi" class="space-y-1.5">
        <label class="block text-sm font-semibold text-blue-500">Câu hỏi (VI)</label>
        <UTextarea v-model="model.question_vi" placeholder="Câu hỏi (VI)" :rows="2" size="md" class="w-full" />
      </div>
    </div>

    <!-- Mode + Allow other -->
    <div class="grid grid-cols-2 gap-4">
      <div class="space-y-1.5">
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Selection mode</label>
        <USelect v-model="model.mode" :items="modeOptions" size="md" class="w-full" />
      </div>
      <div class="flex items-end pb-1">
        <label class="flex items-center gap-2.5 cursor-pointer select-none">
          <USwitch v-model="model.allow_other" size="md" />
          <div>
            <p class="text-sm font-medium text-gray-700 dark:text-gray-300">Allow “Other”</p>
            <p class="text-xs text-gray-400">Let user type a custom answer</p>
          </div>
        </label>
      </div>
    </div>

    <!-- Options -->
    <div class="space-y-3">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-semibold text-gray-700 dark:text-gray-200">Options</p>
          <p class="text-xs text-gray-400">{{ options.length }} option{{ options.length !== 1 ? 's' : '' }}</p>
        </div>
        <UButton icon="i-heroicons-plus" size="sm" color="primary" variant="soft" @click="addOption">Add Option</UButton>
      </div>

      <div v-if="options.length === 0" class="flex flex-col items-center py-6 rounded-lg border border-dashed border-gray-200 dark:border-gray-700 text-center">
        <p class="text-sm text-gray-400">No options yet. Add at least two for a useful question.</p>
      </div>

      <div class="space-y-2">
        <div
          v-for="(opt, i) in options" :key="opt.id"
          class="rounded-lg border border-gray-200 dark:border-gray-700 overflow-hidden"
        >
          <div class="flex items-center justify-between px-3 py-2 bg-gray-50 dark:bg-gray-800/50 border-b border-gray-100 dark:border-gray-700">
            <span class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Option {{ i + 1 }}</span>
            <UButton icon="i-heroicons-trash" size="xs" variant="ghost" color="error" @click="removeOption(i)" />
          </div>
          <div class="p-3" :class="showVi ? 'grid grid-cols-2 gap-3' : ''">
            <div class="space-y-2">
              <UInput v-model="opt.label" placeholder="Option label" size="md" class="w-full" />
              <UInput v-model="opt.description" placeholder="Description (optional)" size="sm" class="w-full" />
            </div>
            <div v-if="showVi" class="space-y-2">
              <UInput v-model="opt.label_vi" placeholder="Nhãn (VI)" size="md" class="w-full" />
              <UInput v-model="opt.description_vi" placeholder="Mô tả (VI)" size="sm" class="w-full" />
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const modeOptions = [
  { label: 'Single Choice', value: 'single' },
  { label: 'Multiple Choice', value: 'multi' },
];

const options = computed(() => model.value.options ?? []);

function addOption() {
  if (!model.value.options) model.value.options = [];
  model.value.options.push({
    id: `opt-${Date.now()}-${Math.random().toString(36).slice(2, 6)}`,
    label: '', label_vi: '', description: '', description_vi: '',
  });
}

function removeOption(idx: number) {
  model.value.options?.splice(idx, 1);
}
</script>
