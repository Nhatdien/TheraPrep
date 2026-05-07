<template>
  <div class="space-y-5">
    <!-- Title -->
    <div :class="showVi ? 'grid grid-cols-2 gap-4' : ''" class="grid">
      <div class="space-y-1.5">
        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-200">Title</label>
        <UInput v-model="model.title" placeholder="Section title (optional)" size="md" class="w-full" />
      </div>
      <div v-if="showVi" class="space-y-1.5">
        <label class="block text-sm font-semibold text-blue-500">Tiêu đề (VI)</label>
        <UInput v-model="model.title_vi" placeholder="Tiêu đề" size="md" class="w-full" />
      </div>
    </div>

    <!-- Content -->
    <div :class="showVi ? 'grid grid-cols-2 gap-4' : ''" class="grid">
      <div class="space-y-1.5">
        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-200">
          Content (HTML) <span class="text-red-500">*</span>
          <span class="text-xs font-normal text-gray-400 ml-1">supports full HTML markup</span>
        </label>
        <UTextarea
          v-model="model.content"
          placeholder="<h3>Section title</h3>&#10;<p>Body content here...</p>"
          :rows="10"
          size="md"
          class="w-full font-mono text-xs"
        />
      </div>
      <div v-if="showVi" class="space-y-1.5">
        <label class="block text-sm font-semibold text-blue-500">Nội dung (VI)</label>
        <UTextarea
          v-model="model.content_vi"
          placeholder="<h3>Tiêu đề</h3>&#10;<p>Nội dung...</p>"
          :rows="10"
          size="md"
          class="w-full font-mono text-xs"
        />
      </div>
    </div>

    <!-- Preview toggle -->
    <div class="rounded-lg border border-gray-200 dark:border-gray-700 overflow-hidden">
      <button
        type="button"
        @click="showPreview = !showPreview"
        class="w-full flex items-center justify-between px-4 py-2.5 text-sm font-medium text-gray-600 dark:text-gray-400 bg-gray-50 dark:bg-gray-800/40 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
      >
        <span class="flex items-center gap-2">
          <UIcon name="i-heroicons-eye" class="w-4 h-4" />
          Preview HTML
        </span>
        <UIcon :name="showPreview ? 'i-heroicons-chevron-up' : 'i-heroicons-chevron-down'" class="w-4 h-4" />
      </button>
      <div v-if="showPreview" class="p-4 prose prose-sm dark:prose-invert max-w-none" v-html="model.content" />
    </div>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const showPreview = ref(false);
</script>
