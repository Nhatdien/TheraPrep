<template>
  <div class="space-y-5">
    <!-- Title -->
    <div :class="showVi ? 'grid grid-cols-2 gap-4' : ''" class="grid">
      <div class="space-y-1.5">
        <label class="block text-sm font-semibold text-gray-700 dark:text-gray-200">Title</label>
        <UInput v-model="model.title" placeholder='e.g. "Great job today!"' size="md" class="w-full" />
      </div>
      <div v-if="showVi" class="space-y-1.5">
        <label class="block text-sm font-semibold text-blue-500">Tiêu đề (VI)</label>
        <UInput v-model="model.title_vi" placeholder="Tiêu đề (VI)" size="md" class="w-full" />
      </div>
    </div>

    <!-- Content -->
    <div :class="showVi ? 'grid grid-cols-2 gap-4' : ''" class="grid">
      <div class="space-y-1.5">
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Content</label>
        <AdminTiptapEditor v-model="model.content" placeholder="Write the completion message..." />
      </div>
      <div v-if="showVi" class="space-y-1.5">
        <label class="block text-sm font-medium text-blue-400">Nội dung (VI)</label>
        <AdminTiptapEditor v-model="model.content_vi" placeholder="Nội dung hoàn thành..." />
      </div>
    </div>

    <!-- Metric label -->
    <div :class="showVi ? 'grid grid-cols-2 gap-4' : ''" class="grid">
      <div class="space-y-1.5">
        <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">Metric label</label>
        <UInput v-model="model.metric_label" placeholder='e.g. "Minutes meditated"' size="md" class="w-full" />
      </div>
      <div v-if="showVi" class="space-y-1.5">
        <label class="block text-sm font-medium text-blue-400">Nhãn chỉ số (VI)</label>
        <UInput v-model="model.metric_label_vi" placeholder="Nhãn chỉ số (VI)" size="md" class="w-full" />
      </div>
    </div>

    <!-- Recommended next -->
    <div class="space-y-3">
      <div class="flex items-center justify-between">
        <div>
          <p class="text-sm font-semibold text-gray-700 dark:text-gray-200">Recommended Next</p>
          <p class="text-xs text-gray-400">Collections to suggest after this one is completed</p>
        </div>
        <UButton icon="i-heroicons-plus" size="sm" color="primary" variant="soft" @click="addRecommended">Add</UButton>
      </div>

      <div v-if="recommended.length === 0" class="flex flex-col items-center py-6 rounded-lg border border-dashed border-gray-200 dark:border-gray-700">
        <p class="text-sm text-gray-400">No recommendations added</p>
      </div>

      <div class="space-y-2">
        <div
          v-for="(rec, i) in recommended" :key="i"
          class="rounded-lg border border-gray-200 dark:border-gray-700 overflow-hidden"
        >
          <div class="flex items-center justify-between px-3 py-2 bg-gray-50 dark:bg-gray-800/50 border-b border-gray-100 dark:border-gray-700">
            <span class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Recommendation {{ i + 1 }}</span>
            <UButton icon="i-heroicons-trash" size="xs" variant="ghost" color="error" @click="removeRecommended(i)" />
          </div>
          <div class="p-3 space-y-3">
            <div class="grid grid-cols-2 gap-3">
              <div class="space-y-1">
                <label class="text-xs font-medium text-gray-500">Collection ID</label>
                <UInput v-model="rec.collection_id" placeholder="collection-id" size="sm" class="w-full" />
              </div>
              <div class="space-y-1">
                <label class="text-xs font-medium text-gray-500">Slide Group ID</label>
                <UInput v-model="rec.slide_group_id" placeholder="group-id" size="sm" class="w-full" />
              </div>
            </div>
            <div :class="showVi ? 'grid grid-cols-2 gap-3' : ''" class="grid">
              <div class="space-y-1">
                <label class="text-xs font-medium text-gray-500">Display Title</label>
                <UInput v-model="rec.title" placeholder="Title shown to user" size="sm" class="w-full" />
              </div>
              <div v-if="showVi" class="space-y-1">
                <label class="text-xs font-medium text-blue-400">Tiêu đề (VI)</label>
                <UInput v-model="rec.title_vi" placeholder="Tiêu đề (VI)" size="sm" class="w-full" />
              </div>
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

const recommended = computed(() => model.value.recommended_next ?? []);

function addRecommended() {
  if (!model.value.recommended_next) model.value.recommended_next = [];
  model.value.recommended_next.push({
    collection_id: '', slide_group_id: '', title: '', title_vi: '',
    description: '', description_vi: '',
  });
}

function removeRecommended(idx: number) {
  model.value.recommended_next?.splice(idx, 1);
}
</script>
