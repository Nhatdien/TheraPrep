/**
 * Media Upload Types
 * Types for image upload, storage, and display throughout the app
 */

export interface MediaFile {
  id: string
  user_id: string
  filename: string
  content_type: string
  size_bytes: number
  r2_key: string
  r2_url: string
  upload_status: 'pending' | 'confirmed' | 'failed'
  created_at: string
}

export interface PresignResponse {
  media_id: string
  upload_url: string
  download_url: string
  expires_at: string
}

export interface JournalEntryMedia {
  id: string
  journal_entry_id: string
  media_file_id: string
  slide_index: number
  position: number
  created_at: string
  // Joined from media_files
  url?: string
  filename?: string
  content_type?: string
  size_bytes?: number
}

export interface SlideMediaAttachment {
  slide_index: number
  media_ids: string[]
}

export interface AttachMediaRequest {
  journal_id: string
  slides: SlideMediaAttachment[]
}

export interface UploadProgress {
  mediaId: string
  file: File
  progress: number // 0-100
  status: 'uploading' | 'done' | 'error'
  previewUrl?: string
  mediaFile?: MediaFile
}

export const ALLOWED_IMAGE_TYPES = [
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/gif',
] as const

export const MAX_FILE_SIZE = 10 * 1024 * 1024 // 10MB
export const MAX_IMAGES_PER_SLIDE = 5