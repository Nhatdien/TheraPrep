<template>
  <div class="space-y-4">
    <div :class="showVi ? 'grid lg:grid-cols-2 gap-4' : ''">
      <UFormField label="Question *">
        <UTextarea v-model="model.question" placeholder="What would you like to know?" :rows="2" />
      </UFormField>
      <UFormField v-if="showVi" label="Question (VI)">
        <UTextarea v-model="model.question_vi" placeholder="Câu hỏi (VI)" :rows="2" />
      </UFormField>
    </div>

    <div class="grid grid-cols-2 gap-4">
      <UFormField label="Selection Mode">
        <USelect v-model="model.mode" :items="modeOptions" />
      </UFormField>
      <UFormField label="Allow 'Other' option">
        <label class="flex items-center gap-2 mt-2 cursor-pointer">
          <input type="checkbox" v-model="model.allow_other" class="rounded" />
          <span class="text-sm">Enable custom input</span>
        </label>
      </UFormField>
    </div>

    <!-- Options -->
    <div>
      <div class="flex items-center justify-between mb-3">
        <span class="text-sm font-medium">Options</span>
        <UButton icon="i-heroicons-plus" size="sm" variant="soft" @click="addOption">Add Option</UButton>
      </div>

      <div class="space-y-2">
        <div
          v-for="(opt, i) in options"
          :key="opt.id"
          class="flex items-start gap-3 p-3 border border-gray-200 dark:border-gray-700 rounded-lg"
        >
          <span class="text-sm text-gray-400 mt-2 w-5">{{ i + 1 }}.</span>
          <div class="flex-1 space-y-2">
            <div :class="showVi ? 'grid grid-cols-2 gap-2' : ''">
              <UInput v-model="opt.label" placeholder="Option label" size="sm" />
              <UInput v-if="showVi" v-model="opt.label_vi" placeholder="Nhãn (VI)" size="sm" />
            </div>
            <div :class="showVi ? 'grid grid-cols-2 gap-2' : ''">
              <UInput v-model="opt.description" placeholder="Description (optional)" size="sm" />
              <UInput v-if="showVi" v-model="opt.description_vi" placeholder="Mô tả (VI)" size="sm" />
            </div>
          </div>
          <UButton icon="i-heroicons-trash" size="xs" variant="ghost" color="error" class="mt-1" @click="removeOption(i)" />
        </div>
      </div>

      <p v-if="options.length === 0" class="text-sm text-gray-400 italic mt-2">No options added yet</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { SlideData, QuestionnaireOption } from '~/types/user_journal';

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
    label: '',
    label_vi: '',
    description: '',
    description_vi: '',
  });
}

function removeOption(idx: number) {
  model.value.options?.splice(idx, 1);
}
</script>
