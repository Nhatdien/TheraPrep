<template>
  <div class="space-y-3">
    <div :class="showVi ? 'grid lg:grid-cols-2 gap-3' : ''">
      <UFormField label="Title">
        <UInput v-model="model.title" placeholder="Section title" size="sm" />
      </UFormField>
      <UFormField v-if="showVi" label="Title (VI)">
        <UInput v-model="model.title_vi" placeholder="Tiêu đề" size="sm" />
      </UFormField>
    </div>

    <div :class="showVi ? 'grid lg:grid-cols-2 gap-3' : ''">
      <UFormField label="Content (HTML) *">
        <UTextarea
          v-model="model.content"
          placeholder="<h3>Title</h3><p>Content...</p>"
          :rows="8"
          size="sm"
          class="font-mono text-xs"
        />
      </UFormField>
      <UFormField v-if="showVi" label="Content (VI)">
        <UTextarea
          v-model="model.content_vi"
          placeholder="<h3>Tiêu đề</h3><p>Nội dung...</p>"
          :rows="8"
          size="sm"
          class="font-mono text-xs"
        />
      </UFormField>
    </div>

    <!-- Preview -->
    <details class="text-xs">
      <summary class="cursor-pointer text-gray-500 hover:text-gray-700">Preview HTML</summary>
      <div class="mt-2 p-3 border border-gray-200 dark:border-gray-700 rounded prose prose-sm dark:prose-invert max-w-none" v-html="model.content" />
    </details>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();
</script>
