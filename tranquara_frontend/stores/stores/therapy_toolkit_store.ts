import { defineStore } from "pinia";
import TranquaraSDK from "../tranquara_sdk";
import { ToolkitRepository } from "~/services/sqlite/toolkit_repository";
import { useAuthStore } from "./auth_store";
import type { TherapySession, HomeworkItem, PrepPack, CreateSessionInput, UpdateSessionInput, UserAffirmation } from "~/types/therapy_toolkit";

const getUserId = (): string | undefined => {
  const authStore = useAuthStore();
  return authStore.getUserUUID || undefined;
};

export const useToolkitStore = defineStore("therapy_toolkit", {
  state: () => ({
    sessions: [] as TherapySession[],
    currentSession: null as TherapySession | null,
    homeworkItems: [] as HomeworkItem[],
    prepPacks: [] as PrepPack[],
    currentPrepPack: null as PrepPack | null,
    affirmations: [] as UserAffirmation[],
    isGeneratingPrepPack: false,
    isLoading: false,
    isSyncing: false,
    isOnline: false,
    error: null as string | null,
  }),

  getters: {
    /** Most recent non-completed session */
    upcomingSession: (state) => {
      return state.sessions.find(s => s.status !== 'completed') || null;
    },

    /** All completed sessions, newest first */
    completedSessions: (state) => {
      return state.sessions.filter(s => s.status === 'completed');
    },

    /** Homework items not yet completed */
    pendingHomework: (state) => {
      return state.homeworkItems.filter(h => !h.completed);
    },

    /** Homework items for a specific session */
    getHomeworkForSession: (state) => {
      return (sessionId: string) => state.homeworkItems.filter(h => h.session_id === sessionId);
    },

    /** Most recently generated prep pack */
    latestPrepPack: (state) => {
      return state.prepPacks.length > 0 ? state.prepPacks[0] : null;
    },
  },

  actions: {
    /** Load sessions + homework + prep packs from SQLite */
    async loadFromLocal() {
      const userId = getUserId();
      if (!userId) return;

      try {
        const repo = new ToolkitRepository();
        this.sessions = await repo.getSessionsByUser(userId);
        this.homeworkItems = await repo.getHomeworkByUser(userId);
        this.prepPacks = await repo.getPrepPacksByUser(userId);
        this.affirmations = await repo.getAffirmationsByUser(userId);
      } catch (error) {
        console.error('[ToolkitStore] Error loading from local:', error);
      }
    },

    /** Create a new therapy session (offline-first) */
    async createSession(input: CreateSessionInput): Promise<TherapySession | null> {
      const userId = getUserId();
      if (!userId) return null;

      const now = new Date().toISOString();
      const session: TherapySession = {
        id: crypto.randomUUID(),
        user_id: userId,
        status: input.status || 'scheduled',
        ...input,
        created_at: now,
        updated_at: now,
        needs_sync: true,
      };

      try {
        const repo = new ToolkitRepository();
        await repo.createSession(session);
        this.sessions.unshift(session);

        // Sync to server if online
        if (this.isOnline) {
          try {
            const response = await TranquaraSDK.getInstance().createSession(input);
            await repo.markSessionSynced(session.id, response.session.id);
            // Update in-memory object so subsequent inline syncs have the server_id
            session.server_id = response.session.id;
            session.needs_sync = false;
          } catch (e) {
            console.warn('[ToolkitStore] Failed to sync session:', e);
          }
        }

        return session;
      } catch (error) {
        console.error('[ToolkitStore] Error creating session:', error);
        return null;
      }
    },

    /** Update an existing session (offline-first) */
    async updateSession(id: string, updates: UpdateSessionInput) {
      try {
        const repo = new ToolkitRepository();
        await repo.updateSession({ id, ...updates });

        const idx = this.sessions.findIndex(s => s.id === id);
        if (idx !== -1) {
          this.sessions[idx] = { ...this.sessions[idx], ...updates, updated_at: new Date().toISOString() };
        }

        if (this.isOnline) {
          try {
            // Use server_id if available so the server can find the record
            const serverId = this.sessions[idx]?.server_id;
            if (serverId) {
              await TranquaraSDK.getInstance().updateSession(serverId, updates);
              await repo.markSessionSynced(id, serverId);
              if (idx !== -1) this.sessions[idx].needs_sync = false;
            }
            // No server_id means session not yet synced — syncPendingItems will handle it
          } catch (e) {
            console.warn('[ToolkitStore] Failed to sync update:', e);
          }
        }
      } catch (error) {
        console.error('[ToolkitStore] Error updating session:', error);
      }
    },

    /** Soft-delete a session */
    async deleteSession(id: string) {
      try {
        // Capture server_id BEFORE removing from state
        const stateSession = this.sessions.find(s => s.id === id);
        const serverId = stateSession?.server_id;

        const repo = new ToolkitRepository();
        await repo.deleteSession(id);
        this.sessions = this.sessions.filter(s => s.id !== id);

        if (this.isOnline && serverId) {
          try {
            await TranquaraSDK.getInstance().deleteSession(serverId);
            await repo.hardDeleteSession(id);
          } catch (e) {
            console.warn('[ToolkitStore] Failed to sync delete:', e);
          }
        }
      } catch (error) {
        console.error('[ToolkitStore] Error deleting session:', error);
      }
    },

    /** Add a homework item to a session */
    async addHomework(sessionId: string, content: string): Promise<HomeworkItem | null> {
      const userId = getUserId();
      if (!userId) return null;

      const item: HomeworkItem = {
        id: crypto.randomUUID(),
        session_id: sessionId,
        user_id: userId,
        content,
        completed: false,
        created_at: new Date().toISOString(),
        needs_sync: true,
      };

      try {
        const repo = new ToolkitRepository();
        await repo.createHomework(item);
        this.homeworkItems.push(item);

        // Sync to server if online — requires session to already have a server_id
        if (this.isOnline) {
          try {
            const session = this.sessions.find(s => s.id === sessionId);
            const sessionServerId = session?.server_id;
            if (sessionServerId) {
              const response = await TranquaraSDK.getInstance().createHomework({
                session_id: sessionServerId,
                content,
              });
              await repo.markHomeworkSynced(item.id, response.homework.id);
              item.server_id = response.homework.id;
              item.needs_sync = false;
            }
            // No sessionServerId — session not yet on server; syncPendingItems will handle it
          } catch (e) {
            console.warn('[ToolkitStore] Failed to sync homework:', e);
          }
        }

        return item;
      } catch (error) {
        console.error('[ToolkitStore] Error adding homework:', error);
        return null;
      }
    },

    /** Toggle homework completed state */
    async toggleHomework(id: string) {
      const item = this.homeworkItems.find(h => h.id === id);
      if (!item) return;

      const newState = !item.completed;
      try {
        const repo = new ToolkitRepository();
        await repo.toggleHomework(id, newState);
        item.completed = newState;
        item.completed_at = newState ? new Date().toISOString() : undefined;

        // Sync to server if online — use server_id
        if (this.isOnline) {
          try {
            const serverId = item.server_id;
            if (serverId) {
              await TranquaraSDK.getInstance().toggleHomework(serverId, newState);
              await repo.markHomeworkSynced(id, serverId);
              item.needs_sync = false;
            }
          } catch (e) {
            console.warn('[ToolkitStore] Failed to sync homework toggle:', e);
          }
        }
      } catch (error) {
        console.error('[ToolkitStore] Error toggling homework:', error);
      }
    },

    /** Delete a homework item */
    async deleteHomework(id: string) {
      try {
        const serverId = this.homeworkItems.find(h => h.id === id)?.server_id;
        const repo = new ToolkitRepository();
        await repo.deleteHomework(id);
        this.homeworkItems = this.homeworkItems.filter(h => h.id !== id);

        // Sync to server if online — use server_id
        if (this.isOnline && serverId) {
          try {
            await TranquaraSDK.getInstance().deleteHomework(serverId);
          } catch (e) {
            console.warn('[ToolkitStore] Failed to sync homework delete:', e);
          }
        }
      } catch (error) {
        console.error('[ToolkitStore] Error deleting homework:', error);
      }
    },

    // ─── Prep Packs ───────────────────────────

    /** Generate an AI prep pack for the given date range */
    async generatePrepPack(dateRangeStart: string, dateRangeEnd: string): Promise<PrepPack | null> {
      const userId = getUserId();
      if (!userId) return null;

      this.isGeneratingPrepPack = true;
      this.error = null;

      try {
        const response = await TranquaraSDK.getInstance().generatePrepPack({
          user_id: userId,
          date_range_start: dateRangeStart,
          date_range_end: dateRangeEnd,
          language: useNuxtApp().$i18n?.locale?.value || 'en',
        });

        // Build local prep pack object with a local ID
        const prepPack: PrepPack = {
          ...response.prep_pack,
          id: crypto.randomUUID(),
          user_id: userId,
          date_range_start: dateRangeStart,
          date_range_end: dateRangeEnd,
          journal_count: response.meta.journals_analyzed,
          created_at: response.meta.generated_at,
        };

        // Persist to SQLite cache
        try {
          const repo = new ToolkitRepository();
          await repo.savePrepPack(prepPack);
        } catch (e) {
          console.warn('[ToolkitStore] Failed to cache prep pack locally:', e);
        }

        // Sync to server if online
        if (this.isOnline) {
          try {
            const { prep_pack: saved } = await TranquaraSDK.getInstance().savePrepPackToServer({
              date_range_start: dateRangeStart,
              date_range_end: dateRangeEnd,
              content: {
                mood_overview: prepPack.mood_overview,
                key_themes: prepPack.key_themes,
                emotional_highlights: prepPack.emotional_highlights,
                patterns: prepPack.patterns,
                discussion_points: prepPack.discussion_points,
                growth_moments: prepPack.growth_moments,
              },
              journal_count: prepPack.journal_count,
              personal_notes: prepPack.personal_notes || null,
            });
            const syncRepo = new ToolkitRepository();
            await syncRepo.markPrepPackSynced(prepPack.id, saved.id);
            prepPack.server_id = saved.id;
            prepPack.needs_sync = false;
          } catch (e) {
            console.warn('[ToolkitStore] Failed to sync prep pack to server:', e);
          }
        }

        // Add to state (newest first)
        this.prepPacks.unshift(prepPack);
        this.currentPrepPack = prepPack;
        return prepPack;
      } catch (error: any) {
        console.error('[ToolkitStore] Error generating prep pack:', error);
        this.error = error?.message || 'Failed to generate prep pack';
        return null;
      } finally {
        this.isGeneratingPrepPack = false;
      }
    },

    /** Load a specific prep pack by ID from local cache */
    async loadPrepPack(id: string): Promise<PrepPack | null> {
      // Check if already in memory
      const cached = this.prepPacks.find(p => p.id === id);
      if (cached) {
        this.currentPrepPack = cached;
        return cached;
      }

      try {
        const repo = new ToolkitRepository();
        const pack = await repo.getPrepPackById(id);
        if (pack) {
          this.currentPrepPack = pack;
        }
        return pack;
      } catch (error) {
        console.error('[ToolkitStore] Error loading prep pack:', error);
        return null;
      }
    },

    /** Delete a prep pack from local cache and server */
    async deletePrepPack(id: string) {
      try {
        const repo = new ToolkitRepository();
        await repo.deletePrepPack(id);
        this.prepPacks = this.prepPacks.filter(p => p.id !== id);
        if (this.currentPrepPack?.id === id) {
          this.currentPrepPack = null;
        }

        // Sync delete to server if online
        if (this.isOnline) {
          try {
            await TranquaraSDK.getInstance().deletePrepPackFromServer(id);
          } catch (e) {
            console.warn('[ToolkitStore] Failed to sync prep pack delete:', e);
          }
        }
      } catch (error) {
        console.error('[ToolkitStore] Error deleting prep pack:', error);
      }
    },

    // --- Affirmations (local-only)

    async addAffirmation(content: string): Promise<UserAffirmation | null> {
      const userId = getUserId();
      if (!userId) return null;

      const item: UserAffirmation = {
        id: crypto.randomUUID(),
        user_id: userId,
        content,
        is_favorite: false,
        created_at: new Date().toISOString(),
      };

      try {
        const repo = new ToolkitRepository();
        await repo.addAffirmation(item);
        this.affirmations.unshift(item);
        return item;
      } catch (error) {
        console.error('[ToolkitStore] Error adding affirmation:', error);
        return null;
      }
    },

    async toggleAffirmationFavorite(id: string) {
      const idx = this.affirmations.findIndex(a => a.id === id);
      if (idx === -1) return;
      const newState = !this.affirmations[idx].is_favorite;

      try {
        const repo = new ToolkitRepository();
        await repo.toggleAffirmationFavorite(id, newState);
        this.affirmations[idx].is_favorite = newState;
      } catch (error) {
        console.error('[ToolkitStore] Error toggling affirmation favorite:', error);
      }
    },

    async deleteAffirmation(id: string) {
      try {
        const repo = new ToolkitRepository();
        await repo.deleteAffirmation(id);
        this.affirmations = this.affirmations.filter(a => a.id !== id);
      } catch (error) {
        console.error('[ToolkitStore] Error deleting affirmation:', error);
      }
    },

    setOnline(online: boolean) {
      this.isOnline = online;
    },

    /**
     * Sync all pending local toolkit items to the server.
     * Called by the background sync plugin on app resume / network restore.
     *
     * Order: sessions → homework (depends on session server_id) → prep packs.
     */
    async syncPendingItems() {
      const userId = getUserId();
      if (!userId || !this.isOnline) return;

      const sdk = TranquaraSDK.getInstance();
      const repo = new ToolkitRepository();

      console.log('[ToolkitStore] Starting pending items sync...');

      // ── 1. Sessions ──────────────────────────────────────────────────────
      try {
        const pendingSessions = await repo.getPendingSyncSessions(userId);
        for (const session of pendingSessions) {
          try {
            if (session.is_deleted) {
              // Soft-deleted session
              if (session.server_id) {
                await sdk.deleteSession(session.server_id);
              }
              // Hard-delete locally regardless (clean up)
              await repo.hardDeleteSession(session.id);
            } else if (!session.server_id) {
              // New session never sent to server
              const { session: created } = await sdk.createSession({
                session_date: session.session_date,
                status: session.status,
                mood_before: session.mood_before,
                talking_points: session.talking_points,
                session_priority: session.session_priority,
                prep_pack_id: session.prep_pack_id,
              });
              await repo.markSessionSynced(session.id, created.id);
            } else {
              // Existing session with pending updates
              await sdk.updateSession(session.server_id, {
                session_date: session.session_date,
                status: session.status,
                mood_before: session.mood_before,
                talking_points: session.talking_points,
                session_priority: session.session_priority,
                prep_pack_id: session.prep_pack_id,
                mood_after: session.mood_after,
                key_takeaways: session.key_takeaways,
                session_rating: session.session_rating,
              });
              await repo.markSessionSynced(session.id, session.server_id);
            }
          } catch (e) {
            console.warn('[ToolkitStore] Failed to sync session:', session.id, e);
          }
        }
      } catch (e) {
        console.error('[ToolkitStore] Error syncing sessions:', e);
      }

      // ── 2. Homework (must run after sessions so server_id is available) ──
      try {
        const pendingHomework = await repo.getPendingSyncHomework(userId);
        for (const item of pendingHomework) {
          try {
            if (!item.server_id) {
              // New homework item — need the parent session's server_id
              const sessionRow = await repo.getSessionById(item.session_id);
              const sessionServerId = sessionRow?.server_id;
              if (!sessionServerId) {
                // Session itself is not synced yet — will be retried next sync
                continue;
              }
              const { homework: created } = await sdk.createHomework({
                session_id: sessionServerId,
                content: item.content,
              });
              await repo.markHomeworkSynced(item.id, created.id);
            } else {
              // Toggle state changed while offline
              await sdk.toggleHomework(item.server_id, !!item.completed);
              await repo.markHomeworkSynced(item.id, item.server_id);
            }
          } catch (e) {
            console.warn('[ToolkitStore] Failed to sync homework:', item.id, e);
          }
        }
      } catch (e) {
        console.error('[ToolkitStore] Error syncing homework:', e);
      }

      // ── 3. Prep Packs ────────────────────────────────────────────────────
      try {
        const pendingPrepPacks = await repo.getPendingSyncPrepPacks(userId);
        for (const pack of pendingPrepPacks) {
          try {
            if (!pack.server_id) {
              const { prep_pack: saved } = await sdk.savePrepPackToServer({
                date_range_start: pack.date_range_start,
                date_range_end: pack.date_range_end,
                content: {
                  mood_overview: pack.mood_overview,
                  key_themes: pack.key_themes,
                  emotional_highlights: pack.emotional_highlights,
                  patterns: pack.patterns,
                  discussion_points: pack.discussion_points,
                  growth_moments: pack.growth_moments,
                },
                journal_count: pack.journal_count,
                personal_notes: pack.personal_notes || null,
              });
              await repo.markPrepPackSynced(pack.id, saved.id);
            }
          } catch (e) {
            console.warn('[ToolkitStore] Failed to sync prep pack:', pack.id, e);
          }
        }
      } catch (e) {
        console.error('[ToolkitStore] Error syncing prep packs:', e);
      }

      console.log('[ToolkitStore] Pending items sync complete');
    },

    /**
     * Download sessions, homework, and prep packs from server into local SQLite.
     * This is the "pull" part of bi-directional sync.
     */
    async syncDownloadFromServer(): Promise<{
      sessions: { inserted: number; updated: number; skipped: number };
      homework: { inserted: number; updated: number; skipped: number };
      prepPacks: { inserted: number; updated: number; skipped: number };
      error?: string;
    }> {
      const empty = { inserted: 0, updated: 0, skipped: 0 };
      const result: {
        sessions: typeof empty;
        homework: typeof empty;
        prepPacks: typeof empty;
        error?: string;
      } = { sessions: { ...empty }, homework: { ...empty }, prepPacks: { ...empty } };

      const userId = getUserId();
      if (!userId) { result.error = 'User not authenticated'; return result; }
      if (!this.isOnline) { result.error = 'Device is offline'; return result; }

      const sdk = TranquaraSDK.getInstance();
      const repo = new ToolkitRepository();

      console.log('[ToolkitStore] Downloading toolkit data from server...');

      // 1. Sessions
      try {
        const res = await sdk.getSessions();
        const serverSessions = res?.sessions || [];
        if (serverSessions.length > 0) {
          result.sessions = await repo.syncSessionsFromServer(serverSessions, userId);
        }
      } catch (e) {
        console.warn('[ToolkitStore] Failed to download sessions:', e);
      }

      // 2. Homework
      try {
        const res = await sdk.getHomework();
        const serverHomework = res?.homework || [];
        if (serverHomework.length > 0) {
          result.homework = await repo.syncHomeworkFromServer(serverHomework, userId);
        }
      } catch (e) {
        console.warn('[ToolkitStore] Failed to download homework:', e);
      }

      // 3. Prep packs
      try {
        const res = await sdk.getPrepPacks();
        const serverPrepPacks = res?.prep_packs || [];
        if (serverPrepPacks.length > 0) {
          result.prepPacks = await repo.syncPrepPacksFromServer(serverPrepPacks, userId);
        }
      } catch (e) {
        console.warn('[ToolkitStore] Failed to download prep packs:', e);
      }

      console.log('[ToolkitStore] Server download complete:', result);
      return result;
    },

    /**
     * Full bi-directional sync (mirrors journal store pattern):
     * 1. Download from server (pull)
     * 2. Upload pending local items (push)
     * 3. Reload local data
     */
    async fullBiDirectionalSync() {
      if (this.isSyncing) {
        console.log('[ToolkitStore] Sync already in progress');
        return;
      }
      if (!this.isOnline) {
        console.log('[ToolkitStore] Offline - skipping full sync');
        return;
      }

      try {
        this.isSyncing = true;
        console.log('[ToolkitStore] Starting full bi-directional sync...');

        // Step 1: Pull from server
        const downloadResult = await this.syncDownloadFromServer();

        // Step 2: Push pending local changes
        await this.syncPendingItems();

        // Step 3: Reload local data to reflect all changes
        await this.loadFromLocal();

        console.log('[ToolkitStore] Full bi-directional sync complete:', downloadResult);
      } catch (error) {
        console.error('[ToolkitStore] Full sync error:', error);
      } finally {
        this.isSyncing = false;
      }
    },
  },
});
