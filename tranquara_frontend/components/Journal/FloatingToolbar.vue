<template>
  <div class="floating-toolbar">
    <!-- Left group: AI + Format -->
    <div class="fab-group">
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

      <button
        class="fab fab-ghost"
        @click="$emit('format-click')"
        aria-label="Format"
      >
        <span class="text-sm font-bold">Aa</span>
      </button>
    </div>

    <!-- Right group: Direction + Mood + Next -->
    <div class="fab-group-right">
      <button
        class="fab fab-dark"
        :disabled="disabled"
        @click="$emit('direction-click')"
        :aria-label="$t('goDeeper.title')"
      >
        <UIcon name="i-lucide-chevron-up" class="text-lg" />
      </button>

      <button
        class="fab fab-dark"
        @click="$emit('mood-click')"
        :aria-label="$t('journal.howFeeling')"
      >
        <UIcon :name="moodIcon" class="text-lg" />
      </button>

      <button
        v-if="showNext"
        class="fab fab-dark"
        @click="$emit('next-click')"
        :aria-label="$t('slide.continue')"
      >
        <UIcon name="i-lucide-chevron-right" class="text-lg" />
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  moodScore?: number;
  loading?: boolean;
  disabled?: boolean;
  showNext?: boolean;
}>();

defineEmits<{
  (e: 'ai-click'): void;
  (e: 'direction-click'): void;
  (e: 'format-click'): void;
  (e: 'mood-click'): void;
  (e: 'next-click'): void;
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
  left: 0;
  right: 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 1rem;
  z-index: 50;
  pointer-events: none;
}

.fab-group,
.fab-group-right {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  pointer-events: auto;
}

.fab-group {
  background: color-mix(in srgb, rgb(var(--ui-bg)) 85%, transparent);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgb(var(--ui-border));
  border-radius: 9999px;
  padding: 0.25rem;
}

.fab {
  width: 2.75rem;
  height: 2.75rem;
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
}

.fab-primary:hover:not(:disabled) {
  filter: brightness(1.1);
}

.fab-ghost {
  background: transparent;
  color: rgb(var(--ui-text));
}

.fab-ghost:hover {
  background: rgb(var(--ui-border));
}

.fab-dark {
  background: color-mix(in srgb, rgb(var(--ui-bg)) 70%, transparent);
  backdrop-filter: blur(12px);
  -webkit-backdrop-filter: blur(12px);
  border: 1px solid rgb(var(--ui-border));
  color: rgb(var(--ui-text));
}

.fab-dark:hover:not(:disabled) {
  background: rgb(var(--ui-border));
}

.fab-loading {
  pointer-events: none;
}
</style>
