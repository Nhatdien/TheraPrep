/**
 * useOfflineMedia - Offline image caching composable
 *
 * Strategy:
 * - When online: images load from R2 URL normally, and are cached via Cache API
 * - When offline: images are served from Cache API
 * - Fallback: placeholder shown if image not cached
 *
 * Uses the browser Cache API which works in both web and Capacitor native WebView.
 */

const CACHE_NAME = 'tranquara-media-v1'
const MAX_CACHE_AGE_MS = 30 * 24 * 60 * 60 * 1000 // 30 days

// Singleton state shared across all component instances
const isOnline = ref(true)
const isInitialized = ref(false)

// Track which URLs have been cached to avoid redundant checks
const cachedUrls = reactive(new Set<string>())

if (import.meta.client && !isInitialized.value) {
  isInitialized.value = true

  // Use Capacitor Network plugin if available, otherwise navigator.onLine
  import('@capacitor/network').then(({ Network }) => {
    Network.getStatus().then((status) => {
      isOnline.value = status.connected
    })
    Network.addListener('networkStatusChange', (status) => {
      isOnline.value = status.connected
    })
  }).catch(() => {
    // Fallback for web: use browser events
    isOnline.value = navigator.onLine
    window.addEventListener('online', () => { isOnline.value = true })
    window.addEventListener('offline', () => { isOnline.value = false })
  })
}

export function useOfflineMedia() {
  /**
   * Cache a single image URL. No-op if already cached.
   */
  async function cacheImage(url: string): Promise<void> {
    if (!import.meta.client) return
    if (!url || cachedUrls.has(url)) return

    try {
      const cache = await caches.open(CACHE_NAME)
      const cached = await cache.match(url)
      if (cached) {
        cachedUrls.add(url)
        return
      }

      // Fetch and cache
      const response = await fetch(url, { mode: 'cors', credentials: 'omit' })
      if (response.ok) {
        await cache.put(url, response)
        cachedUrls.add(url)
      }
    } catch (err) {
      // Silently fail - caching is best-effort
      console.warn('[useOfflineMedia] Failed to cache:', url, err)
    }
  }

  /**
   * Cache multiple image URLs in parallel
   */
  async function cacheImages(urls: string[]): Promise<void> {
    await Promise.allSettled(urls.map(cacheImage))
  }

  /**
   * Get a cached image as a blob URL, or null if not cached.
   * Use this for offline display.
   */
  async function getCachedImageUrl(url: string): Promise<string | null> {
    if (!import.meta.client) return null

    try {
      const cache = await caches.open(CACHE_NAME)
      const cached = await cache.match(url)
      if (!cached) return null

      // Check if cache entry is too old
      const dateHeader = cached.headers.get('date')
      if (dateHeader) {
        const cachedTime = new Date(dateHeader).getTime()
        if (Date.now() - cachedTime > MAX_CACHE_AGE_MS) {
          await cache.delete(url)
          cachedUrls.delete(url)
          return null
        }
      }

      const blob = await cached.blob()
      return URL.createObjectURL(blob)
    } catch {
      return null
    }
  }

  /**
   * Resolve an image URL: returns the best available source.
   * - Online: returns original URL (browser will use HTTP cache)
   * - Offline: returns blob URL from Cache API, or null
   */
  async function resolveImageUrl(url: string): Promise<{ src: string; isOffline: boolean }> {
    if (isOnline.value) {
      // Cache in background for future offline use
      cacheImage(url)
      return { src: url, isOffline: false }
    }

    // Offline: try cache
    const cachedUrl = await getCachedImageUrl(url)
    if (cachedUrl) {
      return { src: cachedUrl, isOffline: true }
    }

    // Not cached - return original and let browser handle the error
    return { src: url, isOffline: true }
  }

  /**
   * Pre-cache images for a journal entry (call when viewing journal detail)
   */
  async function precacheJournalMedia(media: Array<{ url: string }>): Promise<void> {
    if (!isOnline.value) return // Only precache when online
    const urls = media.map(m => m.url).filter(Boolean)
    await cacheImages(urls)
  }

  /**
   * Clear all cached media (e.g., on logout)
   */
  async function clearCache(): Promise<void> {
    if (!import.meta.client) return
    try {
      await caches.delete(CACHE_NAME)
      cachedUrls.clear()
    } catch (err) {
      console.warn('[useOfflineMedia] Failed to clear cache:', err)
    }
  }

  return {
    isOnline: readonly(isOnline),
    cacheImage,
    cacheImages,
    getCachedImageUrl,
    resolveImageUrl,
    precacheJournalMedia,
    clearCache,
  }
}