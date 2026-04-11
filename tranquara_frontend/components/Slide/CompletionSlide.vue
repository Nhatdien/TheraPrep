<template>
  <div class="flex flex-col items-center justify-center h-full px-2">
    <!-- Celebratory header -->
    <div class="text-center mb-8">
      <div class="text-4xl mb-3">🎉</div>
      <h2 class="text-2xl font-bold text-highlighted mb-2">
        {{ displayTitle }}
      </h2>
      <p v-if="displayContent" class="text-sm text-muted leading-relaxed">
        {{ displayContent }}
      </p>
    </div>

    <!-- Metric chip -->
    <div v-if="metricLabel" class="mb-8">
      <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-default bg-elevated text-sm">
        <span class="text-muted">{{ metricLabel }}</span>
      </div>
    </div>

    <!-- Recommended next -->
    <div v-if="recommendedNext.length > 0" class="w-full space-y-3">
      <p class="text-xs uppercase tracking-wide text-toned text-center mb-2">
        {{ locale === 'vi' ? 'Tiếp tục với' : 'Continue with' }}
      </p>
      <button
        v-for="item in recommendedNext"
        :key="item.slide_group_id"
        @click="navigateToNext(item)"
        class="w-full p-4 rounded-xl border border-default bg-elevated hover:bg-muted text-left transition-all duration-200 group"
      >
        <div class="flex items-center justify-between gap-3">
          <div class="min-w-0">
            <h3 class="font-semibold text-sm text-highlighted truncate">
              {{ getNextTitle(item) }}
            </h3>
            <p v-if="getNextDescription(item)" class="text-xs text-muted mt-0.5 line-clamp-2">
              {{ getNextDescription(item) }}
            </p>
          </div>
          <ChevronRight class="w-4 h-4 text-dimmed shrink-0 group-hover:text-highlighted transition-colors" />
        </div>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ChevronRight } from 'lucide-vue-next';
import type { RecommendedNext } from '~/types/user_journal';

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
  slideGroupContext: {
    type: Object,
    default: undefined,
  },
  collectionTitle: {
    type: String,
    default: '',
  },
});

const { locale } = useI18n();
const { openSlideGroup } = useSlideGroup();

const displayTitle = computed(() => {
  if (locale.value === 'vi' && props.content?.title_vi) return props.content.title_vi;
  return props.content?.title || (locale.value === 'vi' ? 'Tuyệt vời!' : 'Well done!');
});

const displayContent = computed(() => {
  if (locale.value === 'vi' && props.content?.content_vi) return props.content.content_vi;
  return props.content?.content || '';
});

const metricLabel = computed(() => {
  if (locale.value === 'vi' && props.content?.metric_label_vi) return props.content.metric_label_vi;
  return props.content?.metric_label || '';
});

const recommendedNext = computed<RecommendedNext[]>(() => props.content?.recommended_next || []);

const getNextTitle = (item: RecommendedNext) => {
  if (locale.value === 'vi' && item.title_vi) return item.title_vi;
  return item.title;
};

const getNextDescription = (item: RecommendedNext) => {
  if (locale.value === 'vi' && item.description_vi) return item.description_vi;
  return item.description;
};

const navigateToNext = (item: RecommendedNext) => {
  openSlideGroup(item.slide_group_id, item.collection_id);
};
</script>
