<template>
  <div
    class="flex flex-col rounded-2xl border border-default overflow-hidden cursor-pointer hover:shadow-md transition-all duration-200 active:scale-[0.98]"
    @click="$emit('click')"
  >
    <!-- Illustration top half -->
    <div class="relative flex items-center justify-center bg-illus-dark aspect-4/3 shrink-0">
      <component :is="illustrationComponent" class="w-24 h-24" />
    </div>

    <!-- Text / progress bottom half -->
    <div class="flex flex-col flex-1 px-4 py-3 bg-elevated gap-2">
      <h3 class="font-semibold text-sm leading-snug line-clamp-2">{{ title }}</h3>
      <p class="text-xs text-muted">
        {{ $t('learnSub.chapters', { count: chapterCount }) }}
      </p>
      <UProgress
        v-if="progress !== undefined"
        :model-value="progress"
        size="sm"
        color="neutral"
        class="mt-auto"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { getIllustrationComponent } from '~/components/Illustrations/index';

const props = defineProps<{
  title: string;
  category?: string;
  chapterCount?: number;
  progress?: number;
}>();

defineEmits<{ click: [] }>();

const illustrationComponent = computed(() =>
  getIllustrationComponent(`${props.category || ''} ${props.title || ''}`)
);
</script>
