<script setup lang="ts">
/**
 * MediaUploader - Upload zone with drag & drop + click + progress
 * Uses Nuxt UI v3 components: UButton, UIcon, UProgress
 */
import { useMediaUpload } from '~/composables/useMediaUpload'
import type { UploadProgress } from '~/types/media'

const props = defineProps<{
  /** Maximum number of images allowed */
  maxImages?: number
  /** Whether the uploader is disabled */
  disabled?: boolean
  /** Currently attached media count (for limit check) */
  currentCount?: number
  /** Initial media items (for edit mode) */
  initialMedia?: Array<{ id: string; url: string; alt?: string }>
}>()

const emit = defineEmits<{
  (e: 'uploaded', mediaId: string, url: string): void
  (e: 'removed', mediaId: string): void
  (e: 'error', message: string): void
}>()

const max = computed(() => props.maxImages ?? 5)
const canAddMore = computed(() => (props.currentCount ?? 0) < max.value)

const {
  uploads,
  isUploading,
  uploadWithProgress,
  deleteMedia,
  removeUpload,
  pickFiles,
  validateFile,
} = useMediaUpload()

const isDragOver = ref(false)

// Pre-populate uploads from initialMedia (edit mode)
onMounted(() => {
  if (props.initialMedia?.length) {
    for (const item of props.initialMedia) {
      const progress: UploadProgress = reactive({
        mediaId: item.id,
        file: new File([], item.url.split('/').pop() || 'image'),
        progress: 100,
        status: 'done' as const,
        previewUrl: item.url,
      })
      uploads.value.set(item.id, progress)
    }
  }
})

async function handleFiles(files: File[]) {
  for (const file of files) {
    if (!canAddMore.value) {
      emit('error', `Maximum ${max.value} images per slide`)
      return
    }

    const validationError = validateFile(file)
    if (validationError) {
      emit('error', validationError)
      continue
    }

    try {
      const mediaFile = await uploadWithProgress(file)
      emit('uploaded', mediaFile.id, mediaFile.r2_url)
    } catch (err: any) {
      emit('error', err.message || 'Upload failed')
    }
  }
}

function onClickAdd() {
  if (!canAddMore.value || props.disabled) return
  pickFiles().then(handleFiles)
}

function onDragOver(e: DragEvent) {
  e.preventDefault()
  if (!props.disabled && canAddMore.value) {
    isDragOver.value = true
  }
}

function onDragLeave() {
  isDragOver.value = false
}

function onDrop(e: DragEvent) {
  e.preventDefault()
  isDragOver.value = false
  if (props.disabled || !canAddMore.value) return
  const files = Array.from(e.dataTransfer?.files || [])
  handleFiles(files)
}

async function onDelete(mediaId: string) {
  try {
    await deleteMedia(mediaId)
    emit('removed', mediaId)
  } catch {
    emit('removed', mediaId)
  }
  removeUpload(mediaId)
}

const uploadList = computed(() => Array.from(uploads.value.values()))
</script>

<template>
  <div class="media-uploader">
    <!-- Thumbnail Strip (when images exist) -->
    <div
      v-if="uploadList.length > 0"
      class="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-hide"
    >
      <!-- Each upload item -->
      <div
        v-for="upload in uploadList"
        :key="upload.mediaId"
        class="relative flex-shrink-0 group"
      >
        <!-- Thumbnail container -->
        <div
          class="w-14 h-14 sm:w-[72px] sm:h-[72px] lg:w-20 lg:h-20 rounded-lg overflow-hidden bg-zinc-800 border border-zinc-700"
          :class="{ 'border-red-500/50': upload.status === 'error' }"
        >
          <!-- Loading shimmer + preview -->
          <div v-if="upload.status === 'uploading'" class="w-full h-full relative">
            <img
              v-if="upload.previewUrl"
              :src="upload.previewUrl"
              class="w-full h-full object-cover opacity-50"
              alt=""
            />
            <div class="absolute inset-0 animate-pulse bg-zinc-700/40" />
          </div>

          <!-- Completed image -->
          <img
            v-else-if="upload.previewUrl && upload.status === 'done'"
            :src="upload.previewUrl"
            class="w-full h-full object-cover"
            alt=""
          />

          <!-- Error state -->
          <div
            v-if="upload.status === 'error'"
            class="w-full h-full flex items-center justify-center bg-zinc-800"
          >
            <UIcon name="i-heroicons-exclamation-triangle" class="w-6 h-6 text-red-400" />
          </div>
        </div>

        <!-- Progress bar (Nuxt UI UProgress) -->
        <div
          v-if="upload.status === 'uploading'"
          class="absolute bottom-0 left-0 right-0 rounded-b-lg overflow-hidden"
        >
          <UProgress :model-value="upload.progress" size="xs" />
        </div>

        <!-- Delete button -->
        <UButton
          v-if="upload.status !== 'uploading'"
          icon="i-heroicons-x-mark"
          variant="solid"
          color="error"
          size="xs"
          class="absolute -top-1.5 -right-1.5 opacity-0 group-hover:opacity-100 group-active:opacity-100 transition-opacity rounded-full"
          @click.stop="onDelete(upload.mediaId)"
        />
      </div>

      <!-- Add more button -->
      <UButton
        v-if="canAddMore"
        icon="i-heroicons-plus"
        variant="outline"
        color="neutral"
        size="sm"
        class="flex-shrink-0 w-14 h-14 sm:w-[72px] sm:h-[72px] lg:w-20 lg:h-20 rounded-lg border-dashed"
        :disabled="disabled || isUploading"
        @click="onClickAdd"
      />
    </div>

    <!-- Empty State: Add Button -->
    <div
      v-else
      @dragover="onDragOver"
      @dragleave="onDragLeave"
      @drop="onDrop"
    >
      <UButton
        icon="i-heroicons-photo"
        variant="ghost"
        color="neutral"
        size="sm"
        :disabled="disabled"
        class="text-zinc-400 hover:text-amber-500"
        :class="{ 'ring-2 ring-amber-500/30 bg-zinc-800/50': isDragOver }"
        @click="onClickAdd"
      >
        <span>{{ $t('journal.addPhoto') || 'Add photo' }}</span>
      </UButton>
    </div>
  </div>
</template>

<style scoped>
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
</style>