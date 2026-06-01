<template>
  <div class="space-y-5">
    <!-- Question -->
    <div :class="showVi ? 'grid grid-cols-2 gap-4' : ''" class="grid">
      <div class="space-y-1.5">
        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-200">
          Question <span class="text-red-500">*</span>
        </label>
        <UTextarea v-model="model.question" placeholder="What do you want to remember to bring up?" :rows="2" size="md" class="w-full" />
      </div>
      <div v-if="showVi" class="space-y-1.5">
        <label class="block text-sm font-semibold text-blue-500">Câu hỏi (VI)</label>
        <UTextarea v-model="model.question_vi" placeholder="Bạn muốn nhớ đề cập điều gì?" :rows="2" size="md" class="w-full" />
      </div>
    </div>

    <!-- Description -->
    <div :class="showVi ? 'grid grid-cols-2 gap-4' : ''" class="grid">
      <div class="space-y-1.5">
        <label class="block text-sm font-medium text-gray-600 dark:text-gray-400">Description <span class="text-gray-400 text-xs">(optional)</span></label>
        <UTextarea v-model="model.content" placeholder="Additional context shown below the question" :rows="2" size="md" class="w-full" />
      </div>
      <div v-if="showVi" class="space-y-1.5">
        <label class="block text-sm font-medium text-blue-400">Mô tả (VI)</label>
        <UTextarea v-model="model.content_vi" placeholder="Mô tả thêm (VI)" :rows="2" size="md" class="w-full" />
      </div>
    </div>

    <!-- Placeholder -->
    <div class="space-y-1.5">
      <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Input placeholder</label>
      <UInput v-model="placeholder" placeholder="Add an item..." size="md" class="w-full" />
      <p class="text-xs text-gray-400">Shown inside the user's text field when it's empty</p>
    </div>
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
