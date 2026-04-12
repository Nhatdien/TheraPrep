<template>
  <div class="relative flex flex-col items-center justify-center h-full px-2 overflow-hidden">
    <!-- CSS particle confetti layer -->
    <div class="particles" aria-hidden="true">
      <span v-for="n in 18" :key="n" class="particle" :style="particleStyle(n)" />
    </div>

    <!-- Brand mark -->
    <BrandLogoMark :size="80" color="#F59E0B" variant="mark" class="mb-6 relative z-10" />

    <!-- Good job headline -->
    <h2 class="text-2xl font-bold text-highlighted mb-2 relative z-10">
      {{ displayTitle }}
    </h2>
    <p v-if="displayContent" class="text-sm text-muted leading-relaxed text-center max-w-xs mb-6 relative z-10">
      {{ displayContent }}
    </p>

    <!-- Metric chip -->
    <div v-if="metricLabel" class="mb-6 relative z-10">
      <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full border border-default bg-elevated text-sm">
        <span class="text-muted">{{ metricLabel }}</span>
      </div>
    </div>

    <!-- Recommended next -->
    <div v-if="recommendedNext.length > 0" class="w-full space-y-3 relative z-10">
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

// Particle confetti positions (deterministic, no random at runtime to avoid hydration mismatch)
const PARTICLE_CONFIGS = [
  { left: 8,  dur: 2.1, delay: 0,    color: '#F59E0B', size: 7 },
  { left: 18, dur: 2.6, delay: 0.3,  color: '#FFFFFF', size: 5 },
  { left: 28, dur: 1.9, delay: 0.6,  color: '#F59E0B', size: 6 },
  { left: 38, dur: 2.4, delay: 0.1,  color: '#FFFFFF', size: 4 },
  { left: 48, dur: 2.0, delay: 0.8,  color: '#F59E0B', size: 8 },
  { left: 58, dur: 2.7, delay: 0.4,  color: '#FFFFFF', size: 5 },
  { left: 68, dur: 1.8, delay: 0.9,  color: '#F59E0B', size: 6 },
  { left: 78, dur: 2.3, delay: 0.2,  color: '#FFFFFF', size: 4 },
  { left: 88, dur: 2.5, delay: 0.7,  color: '#F59E0B', size: 7 },
  { left: 13, dur: 2.2, delay: 1.0,  color: '#FFFFFF', size: 5 },
  { left: 23, dur: 1.7, delay: 0.5,  color: '#F59E0B', size: 4 },
  { left: 33, dur: 2.8, delay: 1.2,  color: '#FFFFFF', size: 6 },
  { left: 43, dur: 2.0, delay: 0.3,  color: '#F59E0B', size: 5 },
  { left: 53, dur: 2.5, delay: 1.4,  color: '#FFFFFF', size: 7 },
  { left: 63, dur: 1.9, delay: 0.6,  color: '#F59E0B', size: 4 },
  { left: 73, dur: 2.3, delay: 1.1,  color: '#FFFFFF', size: 6 },
  { left: 83, dur: 2.6, delay: 0.8,  color: '#F59E0B', size: 5 },
  { left: 93, dur: 2.1, delay: 1.3,  color: '#FFFFFF', size: 4 },
];

const particleStyle = (n: number) => {
  const cfg = PARTICLE_CONFIGS[(n - 1) % PARTICLE_CONFIGS.length];
  return {
    left: `${cfg.left}%`,
    width: `${cfg.size}px`,
    height: `${cfg.size}px`,
    backgroundColor: cfg.color,
    animationDuration: `${cfg.dur}s`,
    animationDelay: `${cfg.delay}s`,
  };
};
</script>

<style scoped>
/* Respect reduced-motion preference */
@media (prefers-reduced-motion: reduce) {
  .particle { animation: none !important; opacity: 0.2; }
}

.particles {
  position: absolute;
  inset: 0;
  pointer-events: none;
  overflow: hidden;
}

.particle {
  position: absolute;
  bottom: -10px;
  border-radius: 50%;
  opacity: 0;
  animation: rise-fade 2s ease-in forwards infinite;
}

@keyframes rise-fade {
  0%   { transform: translateY(0) scale(1);    opacity: 0.9; }
  60%  { opacity: 0.6; }
  100% { transform: translateY(-110%) scale(0.6); opacity: 0; }
}
</style>
