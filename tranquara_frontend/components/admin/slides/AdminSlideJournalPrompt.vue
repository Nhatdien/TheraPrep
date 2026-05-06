<template>
  <div class="space-y-3">
    <div :class="showVi ? 'grid lg:grid-cols-2 gap-3' : ''">
      <UFormField label="Question *">
        <UTextarea v-model="model.question" placeholder="What is on your mind?" size="sm" :rows="2" />
      </UFormField>
      <UFormField v-if="showVi" label="Question (VI)">
        <UTextarea v-model="model.question_vi" placeholder="Bạn đang nghĩ gì?" size="sm" :rows="2" />
      </UFormField>
    </div>

    <div class="grid grid-cols-2 gap-3">
      <UFormField label="Allow AI follow-up">
        <label class="flex items-center gap-2 mt-1">
          <input type="checkbox" v-model="allowAI" class="rounded" />
          <span class="text-sm">Enable AI</span>
        </label>
      </UFormField>
      <UFormField label="Min length (chars)">
        <UInput v-model.number="minLength" type="number" placeholder="0" size="sm" />
      </UFormField>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const allowAI = computed({
  get: () => model.value.config?.allowAI ?? true,
  set: (v) => {
    if (!model.value.config) model.value.config = {};
    model.value.config.allowAI = v;
  },
});

const minLength = computed({
  get: () => model.value.config?.minLength ?? 0,
  set: (v) => {
    if (!model.value.config) model.value.config = {};
    model.value.config.minLength = v || undefined;
  },
});
</script>
