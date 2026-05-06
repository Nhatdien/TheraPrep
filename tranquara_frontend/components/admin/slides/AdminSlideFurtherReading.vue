<template>
  <div class="space-y-3">
    <div class="flex items-center justify-between">
      <span class="text-sm font-medium">Links</span>
      <UButton icon="i-heroicons-plus" size="xs" variant="soft" @click="addLink">Add Link</UButton>
    </div>

    <div v-for="(link, i) in links" :key="i" class="border border-gray-200 dark:border-gray-700 rounded p-3 space-y-2 relative">
      <UButton
        icon="i-heroicons-x-mark"
        size="xs"
        variant="ghost"
        color="error"
        class="absolute top-2 right-2"
        @click="removeLink(i)"
      />
      <UFormField label="Title *">
        <UInput v-model="link.title" placeholder="Link title" size="sm" />
      </UFormField>
      <UFormField label="URL *">
        <UInput v-model="link.url" placeholder="https://..." size="sm" />
      </UFormField>
      <UFormField label="Description">
        <UInput v-model="link.description" placeholder="Optional description" size="sm" />
      </UFormField>
    </div>

    <p v-if="links.length === 0" class="text-xs text-gray-400 italic">No links added yet</p>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const links = computed(() => {
  if (!(model.value as any).links) (model.value as any).links = [];
  return (model.value as any).links as Array<{ title: string; url: string; description?: string }>;
});

function addLink() {
  links.value.push({ title: '', url: '', description: '' });
}

function removeLink(idx: number) {
  links.value.splice(idx, 1);
}
</script>
