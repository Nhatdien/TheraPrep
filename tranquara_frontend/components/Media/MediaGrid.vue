<script setup lang="ts">
/**
 * MediaGrid - 2/3-column grid display for viewing images in journal preview mode
 * Uses Nuxt UI v3: UIcon
 * Click opens MediaLightbox
 */

const props = defineProps<{
  /** Array of image URLs */
  images: Array<{ id?: string; url: string; alt?: string }>
}>()

const lightboxOpen = ref(false)
const lightboxIndex = ref(0)

function openLightbox(index: number) {
  lightboxIndex.value = index
  lightboxOpen.value = true
}
</script>

<template>
  <div v-if="images.length > 0" class="media-grid">
    <!-- Single image: full width -->
    <div v-if="images.length === 1" class="w-full">
      <button
        class="w-full rounded-lg overflow-hidden focus:outline-none focus:ring-2 focus:ring-amber-500"
        @click="openLightbox(0)"
      >
        <MediaCachedImage
          :src="images[0].url"
          :alt="images[0].alt || ''"
          class="w-full aspect-video object-cover hover:scale-[1.02] transition-transform duration-200"
        />
      </button>
    </div>

    <!-- Multiple images: grid -->
    <div
      v-else
      class="grid gap-2 sm:gap-3"
      :class="images.length === 2 ? 'grid-cols-2' : 'grid-cols-2 sm:grid-cols-3'"
    >
      <button
        v-for="(img, idx) in images.slice(0, 6)"
        :key="img.id || idx"
        class="relative rounded-lg overflow-hidden focus:outline-none focus:ring-2 focus:ring-amber-500 group aspect-square"
        @click="openLightbox(idx)"
      >
        <MediaCachedImage
          :src="img.url"
          :alt="img.alt || ''"
          class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-200"
        />
        <!-- "+N" overlay for last visible image when > 6 -->
        <div
          v-if="idx === 5 && images.length > 6"
          class="absolute inset-0 bg-black/60 flex items-center justify-center text-white text-lg font-semibold"
        >
          +{{ images.length - 6 }}
        </div>
      </button>
    </div>

    <!-- Lightbox -->
    <MediaLightbox
      v-model="lightboxOpen"
      :images="images.map((img) => ({ url: img.url, alt: img.alt }))"
      :initial-index="lightboxIndex"
    />
  </div>
</template>