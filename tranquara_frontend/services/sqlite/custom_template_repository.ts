/**
 * Custom Template Repository
 *
 * SQLite CRUD for the user_custom_template table (one row per user).
 */

import { SQLiteDBConnection } from '@capacitor-community/sqlite';
import SQLiteService from './sqlite_service';

export interface LocalCustomTemplate {
  user_id: string;
  title: string;
  /** JSON-serialised SlideGroup[] */
  slide_groups: string;
  updated_at: string;
  needs_sync: number;
}

export class CustomTemplateRepository {
  private getDb(): SQLiteDBConnection {
    if (!SQLiteService.isReady()) {
      throw new Error('Database not initialized');
    }
    return SQLiteService.getConnection();
  }

  private async persistToStore(): Promise<void> {
    await SQLiteService.saveToStore();
  }

  /**
   * Load the custom template for a user.
   * Returns null if none exists yet.
   */
  async get(userId: string): Promise<LocalCustomTemplate | null> {
    const db = this.getDb();
    const result = await db.query(
      'SELECT user_id, title, slide_groups, updated_at, needs_sync FROM user_custom_template WHERE user_id = ?;',
      [userId]
    );
    if (!result.values || result.values.length === 0) return null;
    return result.values[0] as LocalCustomTemplate;
  }

  /**
   * Upsert the custom template for a user.
   */
  async save(userId: string, title: string, slideGroupsJson: string): Promise<LocalCustomTemplate> {
    const db = this.getDb();
    const now = new Date().toISOString();

    await db.run(
      `INSERT INTO user_custom_template (user_id, title, slide_groups, updated_at, needs_sync)
       VALUES (?, ?, ?, ?, 1)
       ON CONFLICT(user_id) DO UPDATE SET
         title        = excluded.title,
         slide_groups = excluded.slide_groups,
         updated_at   = excluded.updated_at,
         needs_sync   = 1;`,
      [userId, title, slideGroupsJson, now]
    );

    await this.persistToStore();

    return {
      user_id: userId,
      title,
      slide_groups: slideGroupsJson,
      updated_at: now,
      needs_sync: 1,
    };
  }

  /**
   * Mark the template as synced (needs_sync = 0).
   */
  async markSynced(userId: string): Promise<void> {
    const db = this.getDb();
    await db.run(
      'UPDATE user_custom_template SET needs_sync = 0 WHERE user_id = ?;',
      [userId]
    );
    await this.persistToStore();
  }
}

export default new CustomTemplateRepository();
