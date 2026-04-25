/**
 * Notification Service
 *
 * Wraps @capacitor/local-notifications to schedule and cancel
 * daily repeating reminders for morning and evening check-ins.
 * On web (Capacitor not available) all methods are no-ops.
 */

import { Capacitor } from '@capacitor/core';
import { LocalNotifications } from '@capacitor/local-notifications';

// Stable IDs so we can cancel by ID later
const MORNING_NOTIFICATION_ID = 1001;
const EVENING_NOTIFICATION_ID = 1002;

class NotificationService {
  private isNative(): boolean {
    return Capacitor.isNativePlatform();
  }

  /**
   * Request local notification permission.
   * Must be called before scheduling on first app launch.
   * Returns true if granted, false otherwise.
   */
  async requestPermission(): Promise<boolean> {
    if (!this.isNative()) return false;
    try {
      const result = await LocalNotifications.requestPermissions();
      return result.display === 'granted';
    } catch (e) {
      console.warn('[NotificationService] requestPermission failed:', e);
      return false;
    }
  }

  /**
   * Check current permission status without prompting.
   */
  async hasPermission(): Promise<boolean> {
    if (!this.isNative()) return false;
    try {
      const result = await LocalNotifications.checkPermissions();
      return result.display === 'granted';
    } catch {
      return false;
    }
  }

  /**
   * Schedule a daily repeating reminder.
   * @param type   'morning' or 'evening'
   * @param time   Time string in "HH:mm" format (24-hour)
   */
  async scheduleReminder(type: 'morning' | 'evening', time: string): Promise<void> {
    if (!this.isNative()) return;

    const [hourStr, minuteStr] = time.split(':');
    const hour = parseInt(hourStr, 10);
    const minute = parseInt(minuteStr, 10);

    if (isNaN(hour) || isNaN(minute)) {
      console.warn('[NotificationService] Invalid time format:', time);
      return;
    }

    const id = type === 'morning' ? MORNING_NOTIFICATION_ID : EVENING_NOTIFICATION_ID;
    const title = type === 'morning' ? '🌅 Morning Check-In' : '🌙 Evening Reflection';
    const body = type === 'morning'
      ? 'Start your day with a quick mindfulness check-in.'
      : 'Take a moment to reflect on your day.';

    // Cancel existing before rescheduling to avoid duplicates
    await this.cancelReminder(type);

    try {
      // Build a schedule date for the next occurrence of the given time
      const now = new Date();
      const scheduleAt = new Date();
      scheduleAt.setHours(hour, minute, 0, 0);
      // If the time today has already passed, schedule for tomorrow
      if (scheduleAt <= now) {
        scheduleAt.setDate(scheduleAt.getDate() + 1);
      }

      await LocalNotifications.schedule({
        notifications: [
          {
            id,
            title,
            body,
            schedule: {
              at: scheduleAt,
              every: 'day',
              allowWhileIdle: true,
            },
            smallIcon: 'ic_stat_notification',
            channelId: 'reminders',
          },
        ],
      });

      console.log(`[NotificationService] Scheduled ${type} reminder at ${time}`);
    } catch (e) {
      console.error(`[NotificationService] Failed to schedule ${type} reminder:`, e);
    }
  }

  /**
   * Cancel a previously scheduled daily reminder.
   */
  async cancelReminder(type: 'morning' | 'evening'): Promise<void> {
    if (!this.isNative()) return;
    const id = type === 'morning' ? MORNING_NOTIFICATION_ID : EVENING_NOTIFICATION_ID;
    try {
      await LocalNotifications.cancel({ notifications: [{ id }] });
      console.log(`[NotificationService] Cancelled ${type} reminder`);
    } catch (e) {
      console.warn(`[NotificationService] Failed to cancel ${type} reminder:`, e);
    }
  }

  /**
   * Re-apply all active reminders from saved settings.
   * Call this on app start (after loading settings) to restore
   * notifications after device restart or app reinstall.
   */
  async rehydrateFromSettings(settings: {
    morning_enabled: boolean;
    morning_time: string;
    evening_enabled: boolean;
    evening_time: string;
  }): Promise<void> {
    if (!this.isNative()) return;
    const hasPerms = await this.hasPermission();
    if (!hasPerms) return;

    if (settings.morning_enabled) {
      await this.scheduleReminder('morning', settings.morning_time);
    } else {
      await this.cancelReminder('morning');
    }

    if (settings.evening_enabled) {
      await this.scheduleReminder('evening', settings.evening_time);
    } else {
      await this.cancelReminder('evening');
    }
  }
}

export default new NotificationService();
