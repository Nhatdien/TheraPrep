<script setup lang="ts">
import { useOfflineMedia } from '~/composables/useOfflineMedia'

const props = defineProps<{
  images: Array<{ url: string; alt?: string }>
  mode?: 'homepage' | 'history'
}>()

const { precacheJournalMedia, isOnline } = useOfflineMedia()

const mode = computed(() => props.mode ?? 'homepage')
const displayImages = computed(() => mode.value === 'history' ? props.images.slice(0, 1) : props.images.slice(0, 2))
const overflowCount = computed(() => mode.value === 'history' ? 0 : Math.max(0, props.images.length - 2))
const lightboxOpen = ref(false)
const lightboxIndex = ref(0)
function openLightbox(idx: number) { lightboxIndex.value = idx; lightboxOpen.value = true }

// Pre-cache images when component mounts (background, non-blocking)
onMounted(() => {
  if (props.images.length > 0) {
    precacheJournalMedia(props.images)
  }
})
</script>

<template>
  <div v-if="images.length > 0" class="media-card-preview">
    <!-- Homepage: 2 thumbnails -->
    <div v-if="mode === 'homepage'" class="flex gap-1.5 mt-2">
      <button v-for="(img, idx) in displayImages" :key="idx"
        class="relative flex-shrink-0 rounded-lg overflow-hidden focus:outline-none focus:ring-1 focus:ring-amber-500"
        @click="openLightbox(idx)">
        <MediaCachedImage :src="img.url" :alt="img.alt || ''" class="w-16 h-16 sm:w-20 sm:h-20 object-cover" />
        <div v-if="idx === 1 && overflowCount > 0" class="absolute inset-0 bg-black/60 flex items-center justify-center text-white text-xs font-semibold">+{{ overflowCount }}</div>
      </button>
    </div>
    <!-- History: cover image -->
    <div v-else class="flex-shrink-0">
      <button class="rounded-lg overflow-hidden focus:outline-none focus:ring-1 focus:ring-amber-500" @click="openLightbox(0)">
        <MediaCachedImage :src="displayImages[0].url" :alt="displayImages[0].alt || ''" class="w-16 h-16 sm:w-20 sm:h-20 lg:w-24 lg:h-24 object-cover" />
      </button>
    </div>
    <MediaLightbox v-model="lightboxOpen" :images="images.map((img) => ({ url: img.url, alt: img.alt }))" :initial-index="lightboxIndex" />
  </div>
</template>