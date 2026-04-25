<template>
  <div class="relative" :style="{ width: `${size}px`, height: `${size}px` }">
    <!-- Background ring -->
    <svg :width="size" :height="size" class="absolute inset-0">
      <circle
        :cx="center"
        :cy="center"
        :r="radius"
        fill="none"
        stroke="currentColor"
        class="text-zinc-800"
        :stroke-width="strokeWidth"
      />
    </svg>

    <!-- Animated progress ring -->
    <svg
      :width="size"
      :height="size"
      class="absolute inset-0 -rotate-90 transition-transform"
      :style="ringScale"
    >
      <defs>
        <linearGradient :id="gradientId" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" :stop-color="phaseColor" />
          <stop offset="100%" :stop-color="phaseColorEnd" />
        </linearGradient>
      </defs>
      <circle
        :cx="center"
        :cy="center"
        :r="radius"
        fill="none"
        :stroke="`url(#${gradientId})`"
        :stroke-width="strokeWidth"
        stroke-linecap="round"
        :stroke-dasharray="circumference"
        :stroke-dashoffset="dashOffset"
        class="transition-all duration-1000 ease-linear"
      />
    </svg>

    <!-- Glow effect -->
    <div
      v-if="isRunning"
      class="absolute inset-0 rounded-full transition-opacity duration-500"
      :style="{
        boxShadow: `0 0 ${glowSize}px ${glowSize / 2}px ${phaseColor}20`,
        opacity: glowOpacity,
      }"
    />

    <!-- Center content -->
    <div class="absolute inset-0 flex flex-col items-center justify-center">
      <slot />
    </div>
  </div>
</template>

<script lang="ts" setup>
const props = withDefaults(defineProps<{
  size?: number;
  strokeWidth?: number;
  phase: 'inhale' | 'holdIn' | 'exhale' | 'holdOut' | 'idle';
  /** 0–1 progress within current phase */
  progress: number;
  isRunning: boolean;
}>(), {
  size: 220,
  strokeWidth: 4,
});

const gradientId = `breathing-grad-${Math.random().toString(36).slice(2, 8)}`;

const center = computed(() => props.size / 2);
const radius = computed(() => (props.size - props.strokeWidth) / 2 - 2);
const circumference = computed(() => 2 * Math.PI * radius.value);

const dashOffset = computed(() => {
  if (!props.isRunning) return circumference.value;
  return circumference.value * (1 - props.progress);
});

const phaseColors: Record<string, [string, string]> = {
  inhale: ['#60A5FA', '#3B82F6'],   // blue
  holdIn: ['#FBBF24', '#F59E0B'],   // amber
  exhale: ['#34D399', '#10B981'],   // green
  holdOut: ['#A78BFA', '#8B5CF6'],  // purple
  idle: ['#71717A', '#52525B'],     // zinc
};

const phaseColor = computed(() => phaseColors[props.phase]?.[0] ?? phaseColors.idle[0]);
const phaseColorEnd = computed(() => phaseColors[props.phase]?.[1] ?? phaseColors.idle[1]);

const ringScale = computed(() => {
  if (!props.isRunning) return { transform: 'scale(0.85) rotate(-90deg)' };
  if (props.phase === 'inhale') return { transform: `scale(${0.85 + 0.15 * props.progress}) rotate(-90deg)` };
  if (props.phase === 'exhale') return { transform: `scale(${1.0 - 0.15 * props.progress}) rotate(-90deg)` };
  return { transform: 'rotate(-90deg)' };
});

const glowSize = computed(() => {
  if (props.phase === 'inhale') return 20 + 10 * props.progress;
  if (props.phase === 'exhale') return 30 - 10 * props.progress;
  return 20;
});

const glowOpacity = computed(() => {
  if (props.phase === 'holdIn' || props.phase === 'holdOut') return 0.4;
  return 0.6;
});
</script>
