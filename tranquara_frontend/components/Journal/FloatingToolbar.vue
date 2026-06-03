<template>
  <div class="floating-toolbar">
    <!-- AI Button -->
    <button
      class="fab fab-primary"
      :disabled="disabled"
      :class="{ 'fab-loading': loading }"
      @click="$emit('ai-click')"
      :aria-label="$t('goDeeper.button')"
    >
      <span v-if="loading" class="inline-block w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
      <UIcon v-else name="i-lucide-sparkles" class="text-lg" />
    </button>

    <!-- Direction Button -->
    <button
      class="fab fab-secondary"
      :disabled="disabled"
      @click="$emit('direction-click')"
      :aria-label="$t('goDeeper.title')"
    >
      <UIcon name="i-lucide-chevron-down" class="text-lg" />
    </button>

    <!-- Format Button -->
    <button
      class="fab fab-secondary"
      @click="$emit('format-click')"
      aria-label="Format"
    >
      <span class="text-sm font-bold">Aa</span>
    </button>

    <!-- Mood Button -->
    <button
      class="fab fab-secondary"
      @click="$emit('mood-click')"
      :aria-label="$t('journal.howFeeling')"
    >
      <UIcon :name="moodIcon" class="text-lg" />
    </button>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  moodScore?: number;
  loading?: boolean;
  disabled?: boolean;
}>();

defineEmits<{
  (e: 'ai-click'): void;
  (e: 'direction-click'): void;
  (e: 'format-click'): void;
  (e: 'mood-click'): void;
}>();

const moodIcon = computed(() => {
  const v = props.moodScore ?? 5;
  if (v <= 4) return 'i-lucide-frown';
  if (v <= 6) return 'i-lucide-meh';
  return 'i-lucide-smile';
});
</script>

<style scoped>
.floating-toolbar {
  position: fixed;
  bottom: calc(1rem + env(safe-area-inset-bottom));
  left: 50%;
  transform: translateX(-50%);
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 0.5rem 1rem;
  border-radius: 9999px;
  background: color-mix(in srgb, rgb(var(--ui-bg)) 80%, transparent);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgb(var(--ui-border));
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.12);
  z-index: 50;
}

.fab {
  width: 3rem;
  height: 3rem;
  border-radius: 9999px;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.15s ease, background-color 0.2s ease;
  cursor: pointer;
  border: none;
  outline: none;
}

.fab:active {
  transform: scale(0.92);
}

.fab:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.fab-primary {
  background: rgb(var(--ui-primary));
  color: rgb(var(--ui-bg));
  box-shadow: 0 4px 12px rgba(var(--ui-primary), 0.3);
}

.fab-primary:hover:not(:disabled) {
  filter: brightness(1.1);
}

.fab-secondary {
  background: rgb(var(--ui-bg));
  color: rgb(var(--ui-text));
  border: 1px solid rgb(var(--ui-border));
}

.fab-secondary:hover:not(:disabled) {
  background: rgb(var(--ui-border));
}

.fab-loading {
  pointer-events: none;
}
</style>
