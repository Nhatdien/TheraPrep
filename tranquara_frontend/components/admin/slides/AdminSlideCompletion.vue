<template>
  <div class="space-y-4">
    <div :class="showVi ? 'grid lg:grid-cols-2 gap-4' : ''">
      <UFormField label="Title">
        <UInput v-model="model.title" placeholder="Completion title (e.g. 'Great job!')" />
      </UFormField>
      <UFormField v-if="showVi" label="Title (VI)">
        <UInput v-model="model.title_vi" placeholder="Tiêu đề (VI)" />
      </UFormField>
    </div>

    <div :class="showVi ? 'grid lg:grid-cols-2 gap-4' : ''">
      <UFormField label="Content">
        <UTextarea v-model="model.content" placeholder="Completion message HTML..." :rows="4" class="font-mono text-xs" />
      </UFormField>
      <UFormField v-if="showVi" label="Content (VI)">
        <UTextarea v-model="model.content_vi" placeholder="Nội dung (VI)..." :rows="4" class="font-mono text-xs" />
      </UFormField>
    </div>

    <div :class="showVi ? 'grid lg:grid-cols-2 gap-4' : ''">
      <UFormField label="Metric Label">
        <UInput v-model="model.metric_label" placeholder="e.g. 'Minutes meditated'" />
      </UFormField>
      <UFormField v-if="showVi" label="Metric Label (VI)">
        <UInput v-model="model.metric_label_vi" placeholder="Nhãn chỉ số (VI)" />
      </UFormField>
    </div>

    <!-- Recommended Next -->
    <div>
      <div class="flex items-center justify-between mb-3">
        <span class="text-sm font-medium">Recommended Next</span>
        <UButton icon="i-heroicons-plus" size="sm" variant="soft" @click="addRecommended">Add</UButton>
      </div>

      <div class="space-y-2">
        <div
          v-for="(rec, i) in recommended"
          :key="i"
          class="p-3 border border-gray-200 dark:border-gray-700 rounded-lg space-y-2 relative"
        >
          <UButton
            icon="i-heroicons-x-mark"
            size="xs"
            variant="ghost"
            color="error"
            class="absolute top-2 right-2"
            @click="removeRecommended(i)"
          />
          <div class="grid grid-cols-2 gap-2">
            <UFormField label="Collection ID">
              <UInput v-model="rec.collection_id" placeholder="collection-id" size="sm" />
            </UFormField>
            <UFormField label="Slide Group ID">
              <UInput v-model="rec.slide_group_id" placeholder="group-id" size="sm" />
            </UFormField>
          </div>
          <div :class="showVi ? 'grid grid-cols-2 gap-2' : ''">
            <UFormField label="Title">
              <UInput v-model="rec.title" placeholder="Recommended title" size="sm" />
            </UFormField>
            <UFormField v-if="showVi" label="Title (VI)">
              <UInput v-model="rec.title_vi" placeholder="Tiêu đề (VI)" size="sm" />
            </UFormField>
          </div>
        </div>
      </div>

      <p v-if="recommended.length === 0" class="text-sm text-gray-400 italic mt-2">No recommendations added</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { SlideData, RecommendedNext } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const recommended = computed(() => model.value.recommended_next ?? []);

function addRecommended() {
  if (!model.value.recommended_next) model.value.recommended_next = [];
  model.value.recommended_next.push({
    collection_id: '',
    slide_group_id: '',
    title: '',
    title_vi: '',
    description: '',
    description_vi: '',
  });
}

function removeRecommended(idx: number) {
  model.value.recommended_next?.splice(idx, 1);
}
</script>
