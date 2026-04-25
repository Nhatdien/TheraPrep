<template>
  <div class="flex flex-col items-center py-10 px-4 text-center">
    <component
      :is="illustration"
      class="w-16 h-16 mb-4 opacity-60"
    />
    <p class="text-sm text-dimmed max-w-xs mb-4">{{ message }}</p>
    <UButton
      v-if="ctaLabel"
      variant="soft"
      color="neutral"
      @click="$emit('action')"
    >
      {{ ctaLabel }}
    </UButton>
  </div>
</template>

<script lang="ts" setup>
import type { Component } from 'vue';

defineProps<{
  illustration: Component;
  message: string;
  ctaLabel?: string;
}>();

defineEmits<{
  (e: 'action'): void;
}>();
</script>
