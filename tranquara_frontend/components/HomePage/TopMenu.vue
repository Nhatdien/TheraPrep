<template>
  <section class="flex justify-between items-center w-full">
    <div class="flex flex-col justify-center items-start w-full gap-y-4">
      <h1>
        {{ greeting }}
        {{ $tranquaraSDK.config.current_username }} 👋
      </h1>
      <div class="flex flex-col gap-4 w-full">
        <UCard variant="soft" class="flex-1 shadow-2xl" size="xl">
          <template #header>
            <div class="flex justify-between items-center">
              <span class="font-semibold">{{ $t('home.yourJourney') }}</span>
            </div>
          </template>
          <div class="flex gap-8 items-center">
            <img
              class="object-fill bg-linear-155 from-primary-200 to-primary-500 max-w-24 rounded-full w-auto black-to-white"
              src="@/assets/img/journaling.png" />
            <div class="w-full">
              <p class="font-semibold text-lg">{{ $t('home.journalingStreak') }}</p>
              <span class="flex gap-1 items-center text-primary-700 font-bold"
                ><Flame /> {{ streakStore.currentStreak }} {{ $t('progress.day', streakStore.currentStreak) }}</span
              >



            </div>
          </div>
        </UCard>
      </div>
    </div>
    <div class="flex items-center gap-4">
      <!-- will be moved to user-auth section -->
    </div>
  </section>
</template>

<script setup lang="ts">
import { useScreen } from "~/composables/useScreen";
import { Flame } from "lucide-vue-next";
import { useUserStreakStore } from "~/stores/stores/user_streak";

const { $tranquaraSDK } = useNuxtApp();
const { t } = useI18n();
const streakStore = useUserStreakStore();
const screen = useScreen();

const greeting = computed(() => {
  const hour = new Date().getHours();
  if (hour < 12) return t('home.greeting.morning');
  if (hour < 18) return t('home.greeting.afternoon');
  return t('home.greeting.evening');
});
</script>

<style scoped>
.flex {
  transition: transform 0.3s ease-in-out;
}

.flex.search-active .logo-section {
  transform: translateX(-300%);
  position: absolute;
}

.user-auth-section {
  flex-shrink: 0;
}
</style>
