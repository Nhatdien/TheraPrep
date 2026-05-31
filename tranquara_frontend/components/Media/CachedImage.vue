<script setup lang="ts">
/**
 * CachedImage - Smart image component with offline support
 *
 * - Online: loads from original URL + caches in background
 * - Offline: loads from Cache API
 * - Error: shows a placeholder with image icon
 */

const props = defineProps<{
  src: string
  alt?: string
  class?: string
  loading?: 'lazy' | 'eager'
}>()

const { resolveImageUrl } = useOfflineMedia()
const resolvedSrc = ref<string | null>(null)
const hasError = ref(false)
const isLoading = ref(true)

// Blob URLs need to be revoked to avoid memory leaks
const currentBlobUrl = ref<string | null>(null)

function revokeCurrentBlob() {
  if (currentBlobUrl.value) {
    URL.revokeObjectURL(currentBlobUrl.value)
    currentBlobUrl.value = null
  }
}

async function loadImage() {
  if (!props.src) {
    hasError.value = true
    isLoading.value = false
    return
  }

  isLoading.value = true
  hasError.value = false

  try {
    const result = await resolveImageUrl(props.src)
    revokeCurrentBlob()

    if (result.isOffline && result.src.startsWith('blob:')) {
      currentBlobUrl.value = result.src
    }

    resolvedSrc.value = result.src
  } catch {
    hasError.value = true
  } finally {
    isLoading.value = false
  }
}

watch(() => props.src, loadImage, { immediate: true })

onUnmounted(() => {
  revokeCurrentBlob()
})

function onError() {
  hasError.value = true
}
</script>

<template>
  <!-- Loading skeleton -->
  <div v-if="isLoading" :class="[$props.class, 'bg-accented animate-pulse flex items-center justify-center']">
    <Icon name="i-lucide-image" class="w-5 h-5 text-dimmed" />
  </div>
  <!-- Error / not available offline -->
  <div v-else-if="hasError || !resolvedSrc" :class="[$props.class, 'bg-accented flex items-center justify-center']">
    <Icon name="i-lucide-image-off" class="w-5 h-5 text-dimmed" />
  </div>
  <!-- Image loaded -->
  <img
    v-else
    :src="resolvedSrc"
    :alt="alt || ''"
    :class="$props.class"
    :loading="loading || 'lazy'"
    @error="onError"
  />
</template>