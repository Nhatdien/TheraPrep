<template>
  <div class="space-y-3">
    <p class="text-xs text-gray-500 italic">Generic editor for slide type: {{ model.type }}</p>

    <div :class="showVi ? 'grid lg:grid-cols-2 gap-3' : ''">
      <UFormField label="Question / Title">
        <UInput v-model="model.question" placeholder="Question text" size="sm" />
      </UFormField>
      <UFormField v-if="showVi" label="Question (VI)">
        <UInput v-model="model.question_vi" placeholder="Câu hỏi (VI)" size="sm" />
      </UFormField>
    </div>

    <UFormField label="Config (JSON)">
      <UTextarea
        :model-value="configJson"
        @update:model-value="updateConfig"
        :rows="4"
        size="sm"
        class="font-mono text-xs"
        placeholder="{}"
      />
      <p v-if="configError" class="text-xs text-red-500 mt-1">{{ configError }}</p>
    </UFormField>
  </div>
</template>

<script setup lang="ts">
import type { SlideData } from '~/types/user_journal';

const model = defineModel<SlideData>({ required: true });
defineProps<{ showVi: boolean }>();

const configError = ref('');

const configJson = computed(() => {
  try {
    return JSON.stringify(model.value.config || {}, null, 2);
  } catch {
    return '{}';
  }
});

function updateConfig(value: string) {
  try {
    model.value.config = JSON.parse(value);
    configError.value = '';
  } catch {
    configError.value = 'Invalid JSON';
  }
}
</script>
