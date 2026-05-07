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
          Content <span class="text-red-500">*</span>
        </label>
        <AdminTiptapEditor v-model="model.content" placeholder="Start writing document content..." />
      </div>
      <div v-if="showVi" class="space-y-1.5">
        <label class="block text-sm font-semibold text-blue-500">Nội dung (VI)</label>
        <AdminTiptapEditor v-model="model.content_vi" placeholder="Nội dung..." />
      </div>
    </div>

  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();
</script>
