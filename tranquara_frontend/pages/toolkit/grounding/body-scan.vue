<template>
  <section class="min-h-screen px-6 pb-20 lg:pb-0 pt-6">
    <!-- Desktop Breadcrumbs -->
    <DesktopBreadcrumb :items="breadcrumbs" />

    <!-- Back Button (mobile) -->
    <div class="mb-6 lg:hidden">
      <UButton variant="ghost" size="lg" icon="i-lucide-chevron-left" @click="navigateTo('/toolkit')" />
    </div>

    <h1 class="text-xl font-semibold mb-2 lg:text-2xl">{{ $t('toolkit.grounding.bodyScan.title') }}</h1>
    <p class="text-muted text-sm mb-6">{{ $t('toolkit.grounding.bodyScan.description') }}</p>

    <!-- Progress dots -->
    <div class="flex items-center justify-center gap-2 mb-6">
      <div
        v-for="(_, i) in partKeys"
        :key="i"
        class="w-2 h-2 rounded-full transition-all duration-300"
        :class="i < currentIndex ? 'bg-green-400' : i === currentIndex ? 'bg-amber-400' : 'bg-zinc-700'"
      />
    </div>

    <!-- Body outline + prompt side by side on desktop, stacked on mobile -->
    <div class="flex flex-col lg:flex-row items-center lg:items-start gap-6 mb-6">
      <!-- Body outline -->
      <div class="flex-shrink-0">
        <ToolkitBodyOutline
          :active-part="partKeys[currentIndex]"
          :is-complete="isComplete"
          class="w-[120px] lg:w-[160px]"
        />
      </div>

      <!-- Focus prompt card -->
      <Transition name="scan-fade" mode="out-in">
        <div :key="currentIndex" class="flex-1 w-full">
          <div class="p-5 rounded-xl border border-amber-500/30 bg-amber-500/5">
            <p class="text-xs text-dimmed mb-1">
              {{ $t('toolkit.grounding.bodyScan.focusOn') }}
            </p>
            <p class="text-xl font-semibold mb-3">{{ currentPart }}</p>
            <p class="text-muted text-sm leading-relaxed">{{ $t('toolkit.grounding.bodyScan.prompt') }}</p>
          </div>
        </div>
      </Transition>
    </div>

    <!-- Navigation -->
    <div class="flex gap-2">
      <UButton
        variant="ghost"
        color="neutral"
        class="flex-1"
        :disabled="currentIndex === 0"
        @click="prevPart"
      >
        {{ $t('common.prev') }}
      </UButton>
      <UButton
        variant="soft"
        color="neutral"
        class="flex-1"
        @click="nextPart"
      >
        {{ currentIndex === partKeys.length - 1 ? $t('common.done') : $t('common.next') }}
      </UButton>
    </div>

    <!-- Completion Overlay -->
    <ToolkitCompletionOverlay
      :show="isComplete"
      :summary="$t('toolkit.completion.bodyScanDone')"
      @done="navigateTo('/toolkit')"
    />
  </section>
</template>

<script lang="ts" setup>
import type { BreadcrumbItem } from '@nuxt/ui'

definePageMeta({ layout: 'detail' });

const { t } = useI18n();

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  { label: t('nav.toolkit'), icon: 'i-lucide-heart-handshake', to: '/toolkit' },
  { label: t('toolkit.grounding.bodyScan.title') },
])

const partKeys = ['head', 'shoulders', 'chest', 'arms', 'stomach', 'legs', 'feet'];

const currentIndex = ref(0);
const isComplete = ref(false);

const currentPart = computed(() => t(`toolkit.grounding.bodyScan.parts.${partKeys[currentIndex.value]}`));

const nextPart = () => {
  if (currentIndex.value < partKeys.length - 1) {
    currentIndex.value += 1;
  } else {
    isComplete.value = true;
  }
};

const prevPart = () => {
  if (currentIndex.value > 0) {
    currentIndex.value -= 1;
  }
};
</script>

<style scoped>
.scan-fade-enter-active,
.scan-fade-leave-active {
  transition: all 0.2s ease;
}
.scan-fade-enter-from {
  opacity: 0;
  transform: translateY(8px);
}
.scan-fade-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>
