<template>
  <section class="min-h-screen px-6 pb-20 lg:pb-0 pt-6">
    <!-- Desktop Breadcrumbs -->
    <DesktopBreadcrumb :items="breadcrumbs" />

    <!-- Back Button (mobile) -->
    <div class="mb-6 lg:hidden">
      <UButton variant="ghost" size="lg" icon="i-lucide-chevron-left" @click="navigateTo('/toolkit')" />
    </div>

    <h1 class="text-xl font-semibold mb-2 lg:text-2xl">{{ $t('toolkit.grounding.fiveSenses.title') }}</h1>
    <p class="text-muted text-sm mb-6">{{ $t('toolkit.grounding.fiveSenses.description') }}</p>

    <!-- Progress dots -->
    <div class="flex items-center justify-center gap-2 mb-6">
      <div
        v-for="(step, i) in steps"
        :key="step.key"
        class="w-2 h-2 rounded-full transition-all duration-300"
        :class="i < currentStepIndex ? 'bg-green-400' : i === currentStepIndex ? stepAccentBg : 'bg-zinc-700'"
      />
    </div>

    <!-- Current step card -->
    <Transition name="sense-slide" mode="out-in">
      <div :key="currentStepIndex" class="mb-6">
        <div class="p-5 rounded-xl border-2 transition-colors duration-300" :class="stepBorderClass">
          <!-- Sense icon + label -->
          <div class="flex items-center gap-3 mb-4">
            <div class="w-10 h-10 rounded-xl flex items-center justify-center" :class="stepIconBg">
              <component :is="currentStep.icon" class="w-5 h-5" :class="stepIconColor" />
            </div>
            <div>
              <p class="text-xs text-dimmed uppercase tracking-wider">
                {{ $t('common.step', { count: currentStepIndex + 1, total: steps.length }) }}
              </p>
              <h2 class="text-sm font-semibold">{{ stepLabel }}</h2>
            </div>
          </div>

          <!-- Inputs -->
          <div class="space-y-3">
            <div
              v-for="(_, i) in currentStep.count"
              :key="i"
              class="flex items-center gap-3"
            >
              <span class="text-xs font-medium w-5 text-center" :class="stepIconColor">{{ i + 1 }}</span>
              <UInput
                v-model="responses[currentStep.key][i]"
                size="sm"
                class="flex-1"
                :placeholder="$t('toolkit.grounding.fiveSenses.inputPlaceholder')"
              />
            </div>
          </div>
        </div>
      </div>
    </Transition>

    <!-- Navigation -->
    <div class="flex gap-2">
      <UButton
        variant="ghost"
        color="neutral"
        class="flex-1"
        :disabled="currentStepIndex === 0"
        @click="prevStep"
      >
        {{ $t('common.prev') }}
      </UButton>
      <UButton
        variant="soft"
        color="neutral"
        class="flex-1"
        @click="nextStep"
      >
        {{ currentStepIndex === steps.length - 1 ? $t('common.done') : $t('common.next') }}
      </UButton>
    </div>

    <!-- Completion Overlay -->
    <ToolkitCompletionOverlay
      :show="isComplete"
      :summary="$t('toolkit.completion.fiveSensesDone')"
      @done="navigateTo('/toolkit')"
    />
  </section>
</template>

<script lang="ts" setup>
import type { BreadcrumbItem } from '@nuxt/ui'
import { Eye, Hand, Ear, Wind, UtensilsCrossed } from 'lucide-vue-next';

definePageMeta({ layout: 'detail' });

const { t } = useI18n();

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  { label: t('nav.toolkit'), icon: 'i-lucide-heart-handshake', to: '/toolkit' },
  { label: t('toolkit.grounding.fiveSenses.title') },
])

const steps = [
  { key: 'see', count: 5, labelKey: 'toolkit.grounding.fiveSenses.steps.see', icon: Eye, accent: 'blue' },
  { key: 'touch', count: 4, labelKey: 'toolkit.grounding.fiveSenses.steps.touch', icon: Hand, accent: 'green' },
  { key: 'hear', count: 3, labelKey: 'toolkit.grounding.fiveSenses.steps.hear', icon: Ear, accent: 'purple' },
  { key: 'smell', count: 2, labelKey: 'toolkit.grounding.fiveSenses.steps.smell', icon: Wind, accent: 'amber' },
  { key: 'taste', count: 1, labelKey: 'toolkit.grounding.fiveSenses.steps.taste', icon: UtensilsCrossed, accent: 'pink' },
];

const currentStepIndex = ref(0);
const isComplete = ref(false);

const responses = reactive<Record<string, string[]>>({
  see: Array(5).fill(''),
  touch: Array(4).fill(''),
  hear: Array(3).fill(''),
  smell: Array(2).fill(''),
  taste: Array(1).fill(''),
});

const currentStep = computed(() => steps[currentStepIndex.value]);
const stepLabel = computed(() => t(currentStep.value.labelKey));

// Accent color classes per sense
const accentMap: Record<string, { border: string; bg: string; text: string; dot: string }> = {
  blue: { border: 'border-blue-500/40 bg-blue-500/5', bg: 'bg-blue-500/15', text: 'text-blue-400', dot: 'bg-blue-400' },
  green: { border: 'border-green-500/40 bg-green-500/5', bg: 'bg-green-500/15', text: 'text-green-400', dot: 'bg-green-400' },
  purple: { border: 'border-purple-500/40 bg-purple-500/5', bg: 'bg-purple-500/15', text: 'text-purple-400', dot: 'bg-purple-400' },
  amber: { border: 'border-amber-500/40 bg-amber-500/5', bg: 'bg-amber-500/15', text: 'text-amber-400', dot: 'bg-amber-400' },
  pink: { border: 'border-pink-500/40 bg-pink-500/5', bg: 'bg-pink-500/15', text: 'text-pink-400', dot: 'bg-pink-400' },
};

const accent = computed(() => accentMap[currentStep.value.accent] || accentMap.blue);
const stepBorderClass = computed(() => accent.value.border);
const stepIconBg = computed(() => accent.value.bg);
const stepIconColor = computed(() => accent.value.text);
const stepAccentBg = computed(() => accent.value.dot);

const nextStep = () => {
  if (currentStepIndex.value < steps.length - 1) {
    currentStepIndex.value += 1;
  } else {
    isComplete.value = true;
  }
};

const prevStep = () => {
  if (currentStepIndex.value > 0) {
    currentStepIndex.value -= 1;
  }
};
</script>

<style scoped>
.sense-slide-enter-active,
.sense-slide-leave-active {
  transition: all 0.25s ease;
}
.sense-slide-enter-from {
  opacity: 0;
  transform: translateX(20px);
}
.sense-slide-leave-to {
  opacity: 0;
  transform: translateX(-20px);
}
</style>
