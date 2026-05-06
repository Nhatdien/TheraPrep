<template>
  <div class="flex items-center justify-between px-4 py-6">
    <!-- Streak Counter -->
    <button class="flex items-center gap-2 px-4 py-2 bg-muted rounded-full cursor-pointer active:scale-95 transition-transform" @click="navigateToProgress">
      <Flame class="w-5 h-5 text-primary" :fill="'currentColor'" />
      <span class="text-sm font-semibold">{{ streak }}</span>
    </button>

    <!-- Date Display (tappable to open date picker) -->
    <button
      class="text-center flex-1 flex flex-col items-center cursor-pointer active:opacity-70"
      @click="$emit('open-date-picker')"
    >
      <h1 class="text-2xl font-bold text-primary lg:text-3xl flex items-center gap-1">
        {{ isToday ? $t('home.today') : formattedDay }}
        <ChevronDown class="w-4 h-4 mt-0.5 text-primary opacity-70" />
      </h1>
      <p class="text-sm text-muted lg:text-base">{{ formattedDate }}</p>
    </button>

    <!-- Profile and Sync Icons (mobile only — sidebar has profile on desktop) -->
    <div class="flex items-center gap-1 lg:invisible">
      <!-- Sync Status Mini Indicator -->
      <SyncMiniIndicator size="sm" @click="navigateToSync" />
      
      <!-- Profile Icon -->
      <NuxtLink to="/profile" class="w-10 h-10 rounded-full bg-muted flex items-center justify-center">
        <User class="w-5 h-5 text-toned" />
      </NuxtLink>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Flame, User, ChevronDown } from "lucide-vue-next";
import { computed } from 'vue';
import { useUserStreakStore } from "~/stores/stores/user_streak";
import { useLocalizedDate } from '~/composables/useLocalizedDate';
import { useHomeDate } from '~/composables/useHomeDate';

defineEmits<{ 'open-date-picker': [] }>();

const router = useRouter();
const streakStore = useUserStreakStore();

const streak = computed(() => streakStore.currentStreak);

const navigateToSync = () => { router.push('/profile#data-sync'); };
const navigateToProgress = () => { router.push('/progress'); };

const { dateLocale } = useLocalizedDate();
const { selectedDate, isToday } = useHomeDate();

// The day name/number shown as the header title when not today
const formattedDay = computed(() => {
  const date = new Date(selectedDate.value + 'T12:00:00');
  return date.toLocaleDateString(dateLocale.value, { weekday: 'long' });
});

const formattedDate = computed(() => {
  const date = new Date(selectedDate.value + 'T12:00:00');
  const month = date.toLocaleDateString(dateLocale.value, { month: 'long' }).toLowerCase();
  const day = date.getDate().toString().padStart(2, '0');
  return `${month}, ${day}`;
});
</script>
