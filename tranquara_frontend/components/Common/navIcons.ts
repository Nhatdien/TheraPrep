import type { Component } from 'vue';
import { defineAsyncComponent } from 'vue';
import {
  BookOpen,
  Clock,
  Home,
  HeartHandshake,
  Settings,
  Flame,
  Smile,
  User,
  type LucideIcon,
} from "lucide-vue-next";

const IconToday = defineAsyncComponent(() => import('../Icons/IconToday.vue'));
const IconInspirations = defineAsyncComponent(() => import('../Icons/IconInspirations.vue'));
const IconLibrary = defineAsyncComponent(() => import('../Icons/IconLibrary.vue'));
const IconHistory = defineAsyncComponent(() => import('../Icons/IconHistory.vue'));

export const navIconComponents: Record<string, Component> = {
  home: IconToday,
  "heart-handshake": IconInspirations,
  "book-open": IconLibrary,
  clock: IconHistory,
  // Fallback Lucide icons for less-common entries
  settings: Settings,
  streaks: Flame,
  emotions: Smile,
  profile: User,
};

export const resolveNavIcon = (iconKey: string): Component => {
  return navIconComponents[iconKey] || Home;
};
