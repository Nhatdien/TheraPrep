<template>
  <section class="min-h-screen flex flex-col items-center justify-center px-6 pb-20 lg:pb-0 relative">
    <!-- Desktop Breadcrumbs (top-left) -->
    <div class="absolute top-4 left-4 z-10">
      <DesktopBreadcrumb :items="breadcrumbs" />
    </div>

    <!-- Back Button (mobile) -->
    <div class="fixed top-4 left-4 z-10 lg:hidden">
      <UButton variant="ghost" size="lg" icon="i-lucide-chevron-left" @click="navigateTo('/toolkit')" />
    </div>

    <!-- Title -->
    <h1 class="text-xl font-semibold mb-2">{{ $t('toolkit.grounding.breathing.title') }}</h1>
    <p class="text-muted text-sm mb-10">{{ $t('toolkit.grounding.breathing.description') }}</p>

    <!-- SVG Breathing Circle -->
    <ToolkitBreathingCircle
      :size="breathingSize"
      :phase="currentPhaseKey"
      :progress="phaseProgress"
      :is-running="isRunning"
      class="mb-6"
    >
      <span v-if="isRunning" class="text-lg font-medium">{{ phaseLabel }}</span>
      <span v-else class="text-dimmed text-sm">{{ $t('toolkit.grounding.breathing.start') }}</span>
    </ToolkitBreathingCircle>

    <!-- Timer -->
    <p v-if="isRunning" class="text-muted text-sm mb-2">
      {{ $t('toolkit.grounding.breathing.elapsed', { time: formattedElapsed }) }}
    </p>

    <!-- Phase countdown -->
    <p v-if="isRunning" class="text-3xl font-bold mb-8 tabular-nums">{{ phaseCountdown }}</p>

    <!-- Start / Stop buttons -->
    <UButton
      v-if="!isRunning && !showComplete"
      variant="solid"
      color="neutral"
      size="xl"
      class="px-12 rounded-full"
      @click="startBreathing"
    >
      {{ $t('toolkit.grounding.breathing.start') }}
    </UButton>

    <UButton
      v-if="isRunning"
      variant="outline"
      color="neutral"
      size="lg"
      class="px-8 rounded-full"
      @click="stopBreathing"
    >
      {{ $t('toolkit.grounding.breathing.stop') }}
    </UButton>

    <!-- Completion Overlay -->
    <ToolkitCompletionOverlay
      :show="showComplete"
      :summary="$t('toolkit.completion.breathingDuration', { duration: formattedElapsed })"
      @done="resetBreathing"
    />
  </section>
</template>

<script lang="ts" setup>
import type { BreadcrumbItem } from '@nuxt/ui'
import { BOX_BREATHING_CONFIG } from '~/types/therapy_toolkit';

definePageMeta({ layout: 'detail' });

const { t } = useI18n();

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  { label: t('nav.toolkit'), icon: 'i-lucide-heart-handshake', to: '/toolkit' },
  { label: t('toolkit.grounding.breathing.title') },
])

// Responsive circle size
const breathingSize = ref(220);
onMounted(() => {
  breathingSize.value = window.innerWidth >= 1024 ? 280 : 220;
});

const config = BOX_BREATHING_CONFIG;
const phases = [
  { key: 'inhale' as const, duration: config.inhale, label: t('toolkit.grounding.breathing.inhale') },
  { key: 'holdIn' as const, duration: config.holdIn, label: t('toolkit.grounding.breathing.holdIn') },
  { key: 'exhale' as const, duration: config.exhale, label: t('toolkit.grounding.breathing.exhale') },
  { key: 'holdOut' as const, duration: config.holdOut, label: t('toolkit.grounding.breathing.holdOut') },
];

const isRunning = ref(false);
const showComplete = ref(false);
const currentPhaseIndex = ref(0);
const phaseCountdown = ref(0);
const elapsedSeconds = ref(0);

let phaseTimer: ReturnType<typeof setInterval> | null = null;
let elapsedTimer: ReturnType<typeof setInterval> | null = null;

const currentPhase = computed(() => phases[currentPhaseIndex.value]);
const phaseLabel = computed(() => currentPhase.value.label);
const currentPhaseKey = computed(() => isRunning.value ? currentPhase.value.key : 'idle' as const);

const phaseProgress = computed(() => {
  if (!isRunning.value) return 0;
  const duration = currentPhase.value.duration;
  return 1 - (phaseCountdown.value / duration);
});

const formattedElapsed = computed(() => {
  const mins = Math.floor(elapsedSeconds.value / 60);
  const secs = elapsedSeconds.value % 60;
  return `${mins}:${String(secs).padStart(2, '0')}`;
});

const startBreathing = () => {
  isRunning.value = true;
  showComplete.value = false;
  currentPhaseIndex.value = 0;
  elapsedSeconds.value = 0;
  phaseCountdown.value = phases[0].duration;

  phaseTimer = setInterval(() => {
    phaseCountdown.value--;
    if (phaseCountdown.value <= 0) {
      currentPhaseIndex.value = (currentPhaseIndex.value + 1) % phases.length;
      phaseCountdown.value = phases[currentPhaseIndex.value].duration;
    }
  }, 1000);

  elapsedTimer = setInterval(() => {
    elapsedSeconds.value++;
  }, 1000);
};

const stopBreathing = () => {
  isRunning.value = false;
  showComplete.value = true;
  if (phaseTimer) clearInterval(phaseTimer);
  if (elapsedTimer) clearInterval(elapsedTimer);
};

const resetBreathing = () => {
  showComplete.value = false;
  elapsedSeconds.value = 0;
};

onUnmounted(() => {
  if (phaseTimer) clearInterval(phaseTimer);
  if (elapsedTimer) clearInterval(elapsedTimer);
});
</script>
