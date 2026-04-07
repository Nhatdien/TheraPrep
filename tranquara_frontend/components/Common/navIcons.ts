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

export const navIconComponents: Record<string, LucideIcon> = {
  home: Home,
  "heart-handshake": HeartHandshake,
  "book-open": BookOpen,
  clock: Clock,
  settings: Settings,
  streaks: Flame,
  emotions: Smile,
  profile: User,
};

export const resolveNavIcon = (iconKey: string): LucideIcon => {
  return navIconComponents[iconKey] || Home;
};
