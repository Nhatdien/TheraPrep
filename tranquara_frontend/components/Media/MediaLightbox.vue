<script setup lang="ts">
/**
 * MediaLightbox - Fullscreen image preview with swipe navigation
 * Uses Nuxt UI v3: UModal, UButton, UIcon
 */

const props = defineProps<{
  /** List of image URLs to display */
  images: Array<{ url: string; alt?: string }>
  /** Currently active image index */
  initialIndex?: number
  /** Whether the lightbox is open */
  modelValue: boolean
}>()

const emit = defineEmits<{
  (e: 'update:modelValue', value: boolean): void
}>()

const currentIndex = ref(props.initialIndex ?? 0)
const touchStartX = ref(0)
const touchStartY = ref(0)

watch(() => props.initialIndex, (val) => {
  if (val !== undefined) currentIndex.value = val
})

const currentImage = computed(() => props.images[currentIndex.value])
const hasPrev = computed(() => currentIndex.value > 0)
const hasNext = computed(() => currentIndex.value < props.images.length - 1)

function close() {
  emit('update:modelValue', false)
}

function prev() {
  if (hasPrev.value) currentIndex.value--
}

function next() {
  if (hasNext.value) currentIndex.value++
}

function onTouchStart(e: TouchEvent) {
  touchStartX.value = e.touches[0].clientX
  touchStartY.value = e.touches[0].clientY
}

function onTouchEnd(e: TouchEvent) {
  const deltaX = e.changedTouches[0].clientX - touchStartX.value
  const deltaY = e.changedTouches[0].clientY - touchStartY.value
  if (Math.abs(deltaX) > Math.abs(deltaY) && Math.abs(deltaX) > 50) {
    if (deltaX > 0) prev()
    else next()
  }
}

function onKeyDown(e: KeyboardEvent) {
  if (!props.modelValue) return
  if (e.key === 'Escape') close()
  if (e.key === 'ArrowLeft') prev()
  if (e.key === 'ArrowRight') next()
}

onMounted(() => window.addEventListener('keydown', onKeyDown))
onUnmounted(() => {
  window.removeEventListener('keydown', onKeyDown)
})

const counterText = computed(() =>
  props.images.length > 1 ? `${currentIndex.value + 1} / ${props.images.length}` : ''
)
</script>

<template>
  <UModal
    :model-value="modelValue"
    fullscreen
    :ui="{
      content: 'bg-black/95',
      overlay: 'bg-black/80',
    }"
    @update:model-value="emit('update:modelValue', $event)"
  >
    <div
      class="relative w-full h-full flex items-center justify-center"
      @touchstart="onTouchStart"
      @touchend="onTouchEnd"
    >
      <!-- Close button -->
      <UButton
        icon="i-heroicons-x-mark"
        variant="ghost"
        color="neutral"
        size="lg"
        class="absolute top-4 right-4 z-10 text-white hover:bg-white/10"
        @click="close"
      />

      <!-- Counter -->
      <span
        v-if="counterText"
        class="absolute top-5 left-5 text-white/70 text-sm font-medium"
      >
        {{ counterText }}
      </span>

      <!-- Image (with offline cache support) -->
      <MediaCachedImage
        v-if="currentImage"
        :src="currentImage.url"
        :alt="currentImage.alt || ''"
        class="max-w-[90vw] max-h-[85vh] object-contain select-none"
        loading="eager"
        @click.stop
      />

      <!-- Prev -->
      <UButton
        v-if="hasPrev"
        icon="i-heroicons-chevron-left"
        variant="ghost"
        color="neutral"
        size="lg"
        class="absolute left-2 sm:left-4 top-1/2 -translate-y-1/2 text-white hover:bg-white/10"
        @click.stop="prev"
      />

      <!-- Next -->
      <UButton
        v-if="hasNext"
        icon="i-heroicons-chevron-right"
        variant="ghost"
        color="neutral"
        size="lg"
        class="absolute right-2 sm:right-4 top-1/2 -translate-y-1/2 text-white hover:bg-white/10"
        @click.stop="next"
      />

      <!-- Dot indicators -->
      <div
        v-if="images.length > 1"
        class="absolute bottom-4 flex gap-2"
      >
        <button
          v-for="(_, idx) in images"
          :key="idx"
          class="w-2 h-2 rounded-full transition-colors"
          :class="idx === currentIndex ? 'bg-amber-500' : 'bg-white/40'"
          @click.stop="currentIndex = idx"
        />
      </div>
    </div>
  </UModal>
</template>