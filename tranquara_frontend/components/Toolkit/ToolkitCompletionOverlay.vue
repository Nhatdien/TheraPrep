<template>
  <Transition name="completion-fade">
    <div
      v-if="show"
      class="fixed inset-0 z-50 flex flex-col items-center justify-center px-6 bg-[var(--ui-bg)]/95 backdrop-blur-sm"
    >
      <!-- Expanding circle -->
      <div class="relative mb-8">
        <div class="w-24 h-24 rounded-full border-2 border-green-500/40 flex items-center justify-center animate-completion-ring">
          <Icon name="i-lucide-check" class="w-10 h-10 text-green-400" />
        </div>
      </div>

      <!-- Title -->
      <h2 class="text-xl font-semibold mb-2">{{ $t('toolkit.completion.title') }}</h2>

      <!-- Summary -->
      <p v-if="summary" class="text-muted text-sm mb-3">{{ summary }}</p>

      <!-- Encouragement -->
      <p class="text-dimmed text-sm italic mb-8 max-w-xs text-center">{{ encouragement }}</p>

      <!-- Done button -->
      <UButton
        variant="soft"
        color="neutral"
        size="lg"
        class="px-10 rounded-full"
        @click="$emit('done')"
      >
        {{ $t('toolkit.completion.done') }}
      </UButton>
    </div>
  </Transition>
</template>

<script lang="ts" setup>
defineProps<{
  show: boolean;
  summary?: string;
}>();

defineEmits<{
  (e: 'done'): void;
}>();

const { t, tm, rt } = useI18n();

const encouragement = computed(() => {
  const raw = tm('toolkit.completion.encouragements');
  if (!Array.isArray(raw)) return '';
  const resolved = raw.map((item: any) => rt(item));
  return resolved[Math.floor(Math.random() * resolved.length)] || '';
});
</script>

<style scoped>
.completion-fade-enter-active {
  transition: opacity 0.4s ease;
}
.completion-fade-leave-active {
  transition: opacity 0.25s ease;
}
.completion-fade-enter-from,
.completion-fade-leave-to {
  opacity: 0;
}

@keyframes completion-ring-expand {
  0% { transform: scale(0.6); opacity: 0; }
  50% { transform: scale(1.1); opacity: 1; }
  100% { transform: scale(1); opacity: 1; }
}
.animate-completion-ring {
  animation: completion-ring-expand 0.6s ease-out;
}
</style>
