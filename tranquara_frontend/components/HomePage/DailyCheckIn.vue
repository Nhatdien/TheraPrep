<template>
  <div class="px-4 mb-6 md:px-0">
    <!-- Check-In Hero Card -->
    <div class="relative rounded-2xl bg-inverted border border-inverted overflow-hidden lg:max-w-2xl lg:mx-auto">
      <!-- Ambient orb animation layer (decorative, behind content) -->
      <div class="ambient-orbs" aria-hidden="true">
        <span class="orb orb-1" />
        <span class="orb orb-2" />
        <span class="orb orb-3" />
        <span class="orb orb-4" />
        <span class="orb orb-5" />
      </div>

      <div class="relative z-10 flex flex-col items-center justify-center px-6 py-12 min-h-[360px] lg:min-h-[280px] lg:py-10">
        <!-- Greeting -->
        <h2 class="text-2xl font-bold text-inverted mb-8">{{ $t(greeting) }}</h2>

        <!-- Begin Button -->
        <UButton
          size="xl"
          color="neutral"
          variant="solid"
          class="px-8 rounded-full font-semibold"
          @click="beginCheckIn">
          {{ $t('home.beginCheckIn') }}
        </UButton>
      </div>
    </div>

  </div>
</template>

<script lang="ts" setup>
import { Bird, BookOpen, Pencil, SlidersHorizontal } from "lucide-vue-next";
import { userJournalStore } from "~/stores/stores/user_journal";

const journalStore = userJournalStore();

// Daily Reflection template ID
const DAILY_REFLECTION_ID = "55555555-5555-5555-5555-555555555555";
const MORNING_SLIDE_GROUP = "morning-prep";
const EVENING_SLIDE_GROUP = "evening-reflection";

// Time-based greeting
const currentHour = ref(new Date().getHours());

const greeting = computed(() => {
  if (currentHour.value < 12) return "home.greeting.morning";
  if (currentHour.value < 17) return "home.greeting.afternoon";
  return "home.greeting.evening";
});

// Pick the right slide group based on time of day
const activeSlideGroupId = computed(() => {
  return currentHour.value < 12 ? MORNING_SLIDE_GROUP : EVENING_SLIDE_GROUP;
});

// Update hour every minute to keep greeting fresh
let intervalId: ReturnType<typeof setInterval>;
onMounted(() => {
  intervalId = setInterval(() => {
    currentHour.value = new Date().getHours();
  }, 60_000);
});
onUnmounted(() => {
  clearInterval(intervalId);
});

// Navigate to the appropriate check-in slide group
const beginCheckIn = () => {
  navigateTo(`/learn_and_prepare/collection/${DAILY_REFLECTION_ID}/${activeSlideGroupId.value}`);
};

// Placeholder for future personalization
const onPersonalize = () => {
  // TODO: Open personalization modal/page
  console.log("[DailyCheckIn] Personalize tapped — not yet implemented");
};
</script>

<style scoped>
/* Respect reduced-motion */
@media (prefers-reduced-motion: reduce) {
  .orb { animation: none !important; }
}

.ambient-orbs {
  position: absolute;
  inset: 0;
  pointer-events: none;
  overflow: hidden;
}

.orb {
  position: absolute;
  border-radius: 50%;
  background: #F59E0B;
  opacity: 0.12;
  filter: blur(28px);
  animation: orb-drift 8s ease-in-out infinite alternate;
}

.orb-1 { width: 120px; height: 120px; top: -30px;  left: -20px;  animation-delay: 0s;    animation-duration: 9s; }
.orb-2 { width: 90px;  height: 90px;  top: 20px;   right: 10px;  animation-delay: 1.5s;  animation-duration: 7s; opacity: 0.1; }
.orb-3 { width: 70px;  height: 70px;  bottom: 10px; left: 30%;   animation-delay: 3s;    animation-duration: 10s; }
.orb-4 { width: 100px; height: 100px; bottom: -20px; right: 20%;  animation-delay: 0.8s;  animation-duration: 8s; opacity: 0.09; }
.orb-5 { width: 60px;  height: 60px;  top: 40%;    left: 60%;   animation-delay: 2.2s;  animation-duration: 11s; opacity: 0.08; }

@keyframes orb-drift {
  0%   { transform: translate(0, 0) scale(1); }
  50%  { transform: translate(12px, -18px) scale(1.1); }
  100% { transform: translate(-8px, 10px) scale(0.95); }
}
</style>
