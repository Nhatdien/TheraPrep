<template>
  <div class="space-y-4">
    <div class="flex items-center justify-between">
      <div>
        <p class="text-sm font-semibold text-gray-700 dark:text-gray-200">Links</p>
        <p class="text-xs text-gray-400">Articles, videos, or resources to recommend</p>
      </div>
      <UButton icon="i-heroicons-plus" size="sm" color="primary" variant="soft" @click="addLink">Add Link</UButton>
    </div>

    <div v-if="links.length === 0" class="flex flex-col items-center py-8 rounded-lg border border-dashed border-gray-200 dark:border-gray-700 text-center">
      <UIcon name="i-heroicons-link" class="w-8 h-8 text-gray-300 dark:text-gray-600 mb-2" />
      <p class="text-sm text-gray-400">No links yet. Add one above.</p>
    </div>

    <div class="space-y-3">
      <div
        v-for="(link, i) in links"
        :key="i"
        class="rounded-lg border border-gray-200 dark:border-gray-700 overflow-hidden"
      >
        <div class="flex items-center justify-between px-3 py-2 bg-gray-50 dark:bg-gray-800/50 border-b border-gray-100 dark:border-gray-700">
          <span class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Link {{ i + 1 }}</span>
          <UButton icon="i-heroicons-trash" size="xs" variant="ghost" color="error" @click="removeLink(i)" />
        </div>
        <div class="p-3 space-y-3">
          <div class="space-y-1.5">
            <label class="block text-xs font-medium text-gray-600 dark:text-gray-400">Title <span class="text-red-500">*</span></label>
            <UInput v-model="link.title" placeholder="e.g. Understanding Anxiety" size="md" class="w-full" />
          </div>
          <div class="space-y-1.5">
            <label class="block text-xs font-medium text-gray-600 dark:text-gray-400">URL <span class="text-red-500">*</span></label>
            <UInput v-model="link.url" placeholder="https://" size="md" class="w-full" icon="i-heroicons-link" />
          </div>
          <div class="space-y-1.5">
            <label class="block text-xs font-medium text-gray-600 dark:text-gray-400">Description</label>
            <UInput v-model="link.description" placeholder="Brief description (optional)" size="md" class="w-full" />
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

const links = computed(() =>
  ((model.value as any).links ?? []) as Array<{ title: string; url: string; description?: string }>
);

function addLink() {
  if (!(model.value as any).links) (model.value as any).links = [];
  (model.value as any).links.push({ title: '', url: '', description: '' });
}

function removeLink(idx: number) {
  (model.value as any).links?.splice(idx, 1);
}
</script>
