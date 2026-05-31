<template>
  <div class="flex flex-col items-center justify-center min-h-full px-4">
    <h2 class="text-2xl font-bold mb-2 text-center text-highlighted">
      {{ displayQuestion }}
    </h2>
    <p v-if="displayContent" class="text-sm text-muted mb-10 text-center">
      {{ displayContent }}
    </p>

    <div class="flex gap-3">
      <button
        v-for="star in 5"
        :key="star"
        @click="selectRating(star)"
        class="transition-transform duration-150"
        :class="[
          star <= rating ? 'text-primary scale-110' : 'text-toned',
          'hover:scale-125 active:scale-95'
        ]"
      >
        <Star :size="40" :fill="star <= rating ? 'currentColor' : 'none'" />
      </button>
    </div>

    <p v-if="rating > 0" class="text-sm text-muted mt-4">
      {{ rating }} / 5
    </p>
  </div>
</template>

<script setup lang="ts">
import { Star } from 'lucide-vue-next';
import { userJournalStore } from '~/stores/stores/user_journal';

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

const displayQuestion = computed(() =>
  props.content?.question || props.content?.question_content || ''
);

const displayContent = computed(() =>
  props.content?.content || props.content?.question_description || ''
);

const rating = ref(0);

const selectRating = (star: number) => {
  rating.value = star;
  store.updateCurrentWritingContent(
    displayQuestion.value,
    String(star)
  );
};
</script>
