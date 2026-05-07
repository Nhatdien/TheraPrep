<template>
  <div class="space-y-3">
    <div :class="showVi ? 'grid lg:grid-cols-2 gap-3' : ''">
      <UFormField label="Question *">
        <UInput v-model="model.question" placeholder="How are you feeling?" size="sm" />
      </UFormField>
      <UFormField v-if="showVi" label="Question (VI)">
        <UInput v-model="model.question_vi" placeholder="Bạn cảm thấy thế nào?" size="sm" />
      </UFormField>
    </div>

    <UFormField label="Scale">
      <UInput model-value="1-10" disabled size="sm" />
    </UFormField>

    <UFormField label="Labels (10 required)">
      <div class="space-y-1">
        <div v-for="(_, i) in 10" :key="i" class="flex items-center gap-2">
          <span class="text-xs text-gray-400 w-4">{{ i + 1 }}</span>
          <UInput
            :model-value="labels[i] || ''"
            @update:model-value="updateLabel(i, $event)"
            :placeholder="`Label ${i + 1}`"
            size="sm"
            class="flex-1"
          />
        </div>
      </div>
      <p v-if="labels.filter(Boolean).length !== 10" class="text-xs text-amber-500 mt-1">
        {{ labels.filter(Boolean).length }}/10 labels filled
      </p>
    </UFormField>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const labels = computed(() => model.value.config?.labels || []);

function updateLabel(idx: number, value: string) {
  if (!model.value.config) model.value.config = { scale: '1-10', labels: [] };
  if (!model.value.config.labels) model.value.config.labels = [];
  while (model.value.config.labels.length < 10) model.value.config.labels.push('');
  model.value.config.labels[idx] = value;
}
</script>
