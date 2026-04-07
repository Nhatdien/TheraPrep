<template>
  <section class="flex flex-col items-center justify-center h-full px-4">
    <h2 class="text-2xl sm:text-3xl font-semibold text-center text-highlighted mb-2">{{ displayQuestion }}</h2>
    <p class="text-sm text-toned text-center mb-8">{{ displayDescription }}</p>

    <div class="w-full max-w-md rounded-2xl border border-default/70 bg-elevated px-5 py-6">
      <div class="flex items-center justify-between text-xs uppercase tracking-wide text-toned mb-4">
        <span>{{ $t('slide.badSleep', 'Restless') }}</span>
        <span>{{ $t('slide.goodSleep', 'Restful') }}</span>
      </div>

      <USlider v-model="sleepScore" :min="0" :max="100" :step="5" />

      <div class="mt-5 text-center transition-all" :style="{ transitionDuration: 'var(--motion-smooth)' }" :class="scoreTone">
        <p class="text-3xl font-semibold">{{ sleepScore }}%</p>
        <p class="text-sm mt-1">{{ scoreLabel }}</p>
      </div>
    </div>
  </section>
</template>

<script lang="ts" setup>
import { userJournalStore } from '~/stores/stores/user_journal';
const { t } = useI18n();

const props = defineProps({
  content: {
    type: Object,
    required: true,
  },
  currentIndex: {
    type: Number,
    required: true,
  },
  index: {
    type: Number,
    required: true,
  },
});

const store = userJournalStore();
const sleepScore = ref(70);

const displayQuestion = computed(() =>
  props.content?.question || props.content?.question_content || t('slide.sleepQuestion')
);

const displayDescription = computed(() =>
  props.content?.content || props.content?.question_description || t('slide.sleepInstruction', 'How restored did you feel when you woke up?')
);

const scoreLabel = computed(() => {
  if (sleepScore.value < 35) return 'You may need gentle recovery today.';
  if (sleepScore.value < 70) return 'A steady day with mindful pacing can help.';
  return 'Great foundation for focus and calm energy.';
});

const scoreTone = computed(() => {
  if (sleepScore.value < 35) return 'text-warning';
  if (sleepScore.value < 70) return 'text-primary';
  return 'text-success';
});

watch(sleepScore, (val) => {
  const questionKey = props.content?.question || props.content?.question_content || 'sleep_score';
  store.updateCurrentWritingContent(questionKey, String(val));
}, { immediate: true });
</script>
