<template>
  <div class="space-y-5">
    <!-- Question -->
    <div class="space-y-1.5">
      <label class="block text-sm font-semibold text-gray-700 dark:text-gray-200">
        Prompt Question <span class="text-red-500">*</span>
        <span class="text-xs font-normal text-gray-400 ml-1">shown to the user above the writing area</span>
      </label>
      <div v-if="!showVi">
        <AdminTiptapEditor v-model="model.question" placeholder="e.g. What's on your mind today?" />
      </div>
      <div v-else class="grid grid-cols-2 gap-4">
        <div class="space-y-1">
          <span class="text-xs font-medium text-gray-400 uppercase tracking-wide">🇬🇧 EN</span>
          <AdminTiptapEditor v-model="model.question" placeholder="e.g. What's on your mind today?" />
        </div>
        <div class="space-y-1">
          <span class="text-xs font-medium text-blue-400 uppercase tracking-wide">🇻🇳 VI</span>
          <AdminTiptapEditor v-model="model.question_vi" placeholder="Bạn đang nghĩ gì hôm nay?" />
        </div>
      </div>
    </div>

    <!-- Min length -->
    <div class="flex items-center gap-4 p-3 rounded-lg bg-gray-50 dark:bg-gray-800/40 border border-gray-100 dark:border-gray-700">
      <div class="flex-1">
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Minimum length</label>
        <p class="text-xs text-gray-400">Require user to write at least this many characters before they can continue</p>
      </div>
      <div class="w-24">
        <UInput v-model.number="minLength" type="number" placeholder="0" size="md" class="w-full" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const minLength = computed({
  get: () => model.value.config?.minLength ?? 0,
  set: (v) => {
    if (!model.value.config) model.value.config = {};
    model.value.config.minLength = v || undefined;
  },
});
</script>
