import type {
  MediaFile,
  PresignResponse,
  UploadProgress,
  AttachMediaRequest,
  SlideMediaAttachment,
} from '~/types/media'

interface MediaUploadOptions {
  /** Max file size in bytes (default: 10MB) */
  maxSize?: number
  /** Max images per slide (default: 5) */
  maxPerSlide?: number
  /** Auto-resize images before upload (default: true) */
  autoResize?: boolean
  /** Max dimension for auto-resize (default: 1920) */
  maxDimension?: number
}

export function useMediaUpload(options: MediaUploadOptions = {}) {
  const {
    maxSize = 10 * 1024 * 1024,
    maxPerSlide = 5,
    autoResize = true,
    maxDimension = 1920,
  } = options

  const { api } = useApi()

  // Reactive upload state
  const uploads = ref<Map<string, UploadProgress>>(new Map())
  const isUploading = computed(() =>
    Array.from(uploads.value.values()).some((u) => u.status === 'uploading')
  )

  /**
   * Validate a file before upload
   */
  function validateFile(file: File): string | null {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'] as const

    if (!allowedTypes.includes(file.type as any)) {
      return 'Unsupported format. Use JPEG, PNG, WebP, or GIF'
    }
    if (file.size > maxSize) {
      return `File too large. Maximum size: ${Math.round(maxSize / 1024 / 1024)}MB`
    }
    return null
  }

  /**
   * Resize an image file if it exceeds maxDimension
   */
  function resizeImage(file: File): Promise<File> {
    return new Promise((resolve) => {
      if (!autoResize) {
        resolve(file)
        return
      }

      const img = new Image()
      const url = URL.createObjectURL(file)

      img.onload = () => {
        URL.revokeObjectURL(url)

        // No resize needed
        if (img.width <= maxDimension && img.height <= maxDimension) {
          resolve(file)
          return
        }

        const scale = Math.min(maxDimension / img.width, maxDimension / img.height)
        const canvas = document.createElement('canvas')
        canvas.width = Math.round(img.width * scale)
        canvas.height = Math.round(img.height * scale)

        const ctx = canvas.getContext('2d')!
        ctx.drawImage(img, 0, 0, canvas.width, canvas.height)

        canvas.toBlob(
          (blob) => {
            if (blob) {
              const resizedFile = new File([blob], file.name, {
                type: file.type,
                lastModified: Date.now(),
              })
              resolve(resizedFile)
            } else {
              resolve(file)
            }
          },
          file.type,
          0.85
        )
      }

      img.onerror = () => {
        URL.revokeObjectURL(url)
        resolve(file)
      }

      img.src = url
    })
  }

  /**
   * Upload a single file to R2 via presigned URL
   */
  async function uploadFile(
    file: File,
    onProgress?: (progress: number) => void
  ): Promise<MediaFile> {
    // 1. Validate
    const error = validateFile(file)
    if (error) {
      throw new Error(error)
    }

    // 2. Resize if needed
    const processedFile = await resizeImage(file)

    // 3. Get presigned URL from backend
    const presignResp: PresignResponse = await api('/api/v1/media/presign', {
      method: 'POST',
      body: {
        filename: processedFile.name,
        content_type: processedFile.type,
        size_bytes: processedFile.size,
      },
    })

    // 4. Upload directly to R2 using XMLHttpRequest for progress tracking
    await new Promise<void>((resolve, reject) => {
      const xhr = new XMLHttpRequest()
      xhr.open('PUT', presignResp.upload_url)
      xhr.setRequestHeader('Content-Type', processedFile.type)

      xhr.upload.onprogress = (e) => {
        if (e.lengthComputable && onProgress) {
          onProgress(Math.round((e.loaded / e.total) * 100))
        }
      }

      xhr.onload = () => {
        if (xhr.status >= 200 && xhr.status < 300) {
          resolve()
        } else {
          reject(new Error(`Upload failed: ${xhr.status}`))
        }
      }

      xhr.onerror = () => reject(new Error('Network error during upload'))
      xhr.send(processedFile)
    })

    // 5. Confirm upload with backend
    const mediaFile: MediaFile = await api(`/api/v1/media/${presignResp.media_id}/confirm`, {
      method: 'POST',
    })

    return mediaFile
  }

  /**
   * Upload a file with progress tracking in the reactive uploads map
   */
  async function uploadWithProgress(file: File): Promise<MediaFile> {
    const tempId = `temp_${Date.now()}_${Math.random().toString(36).slice(2)}`

    // Create preview URL
    const previewUrl = URL.createObjectURL(file)

    const progress: UploadProgress = reactive({
      mediaId: tempId,
      file,
      progress: 0,
      status: 'uploading' as const,
      previewUrl,
    })

    uploads.value.set(tempId, progress)

    try {
      const mediaFile = await uploadFile(file, (p) => {
        progress.progress = p
      })

      progress.status = 'done'
      progress.mediaId = mediaFile.id
      progress.mediaFile = mediaFile

      return mediaFile
    } catch (err) {
      progress.status = 'error'
      throw err
    }
  }

  /**
   * Delete a media file
   */
  async function deleteMedia(mediaId: string): Promise<void> {
    await api(`/api/v1/media/${mediaId}`, {
      method: 'DELETE',
    })
  }

  /**
   * Attach media to journal entry slides
   */
  async function attachToJournal(
    journalId: string,
    slides: SlideMediaAttachment[]
  ): Promise<void> {
    await api('/api/v1/media/attach', {
      method: 'POST',
      body: {
        journal_id: journalId,
        slides,
      } as AttachMediaRequest,
    })
  }

  /**
   * Get all media for a journal entry
   */
  async function getJournalMedia(journalEntryId: string): Promise<MediaFile[]> {
    const resp = await api(`/api/v1/media/journal/${journalEntryId}`)
    return resp.media || []
  }

  /**
   * Remove a tracked upload
   */
  function removeUpload(tempId: string) {
    const upload = uploads.value.get(tempId)
    if (upload?.previewUrl) {
      URL.revokeObjectURL(upload.previewUrl)
    }
    uploads.value.delete(tempId)
  }

  /**
   * Open file picker and return selected files
   */
  function pickFiles(): Promise<File[]> {
    return new Promise((resolve) => {
      const input = document.createElement('input')
      input.type = 'file'
      input.accept = 'image/jpeg,image/png,image/webp,image/gif'
      input.multiple = true
      input.onchange = () => {
        const files = Array.from(input.files || [])
        resolve(files)
      }
      input.click()
    })
  }

  return {
    uploads: readonly(uploads),
    isUploading: readonly(isUploading),
    validateFile,
    uploadFile,
    uploadWithProgress,
    deleteMedia,
    attachToJournal,
    getJournalMedia,
    removeUpload,
    pickFiles,
  }
}