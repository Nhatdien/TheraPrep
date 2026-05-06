<template>
  <div class="space-y-4">
    <div :class="showVi ? 'grid lg:grid-cols-2 gap-4' : ''">
      <UFormField label="Question *">
        <UTextarea v-model="model.question" placeholder="What do you want to remember to bring up?" :rows="2" />
      </UFormField>
      <UFormField v-if="showVi" label="Question (VI)">
        <UTextarea v-model="model.question_vi" placeholder="Câu hỏi (VI)" :rows="2" />
      </UFormField>
    </div>

    <div :class="showVi ? 'grid lg:grid-cols-2 gap-4' : ''">
      <UFormField label="Description (optional)">
        <UTextarea v-model="model.content" placeholder="Additional context shown below the question" :rows="2" />
      </UFormField>
      <UFormField v-if="showVi" label="Description (VI)">
        <UTextarea v-model="model.content_vi" placeholder="Mô tả thêm (VI)" :rows="2" />
      </UFormField>
    </div>

    <UFormField label="Input Placeholder">
      <UInput v-model="placeholder" placeholder="Add an item..." />
      <p class="text-xs text-gray-500 mt-1">Placeholder text shown in the user's input field</p>
    </UFormField>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const placeholder = computed({
  get: () => model.value.config?.placeholder ?? '',
  set: (v) => {
    if (!model.value.config) model.value.config = {};
    model.value.config.placeholder = v || undefined;
  },
});
</script>
