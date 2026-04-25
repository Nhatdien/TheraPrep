<template>
  <div class="flex flex-col w-full min-h-screen pb-20 lg:pb-0">
    <!-- Date Header with Streak -->
    <HomePageDateHeader @open-date-picker="showDatePicker = true" />

    <!-- Daily Check-In (Morning / Evening) -->
    <HomePageDailyCheckIn :selected-date="selectedDate" />

    <!-- Edit template link -->
    <div class="text-center -mt-3 mb-2">
      <NuxtLink to="/settings/my-template" class="text-xs text-muted hover:text-default transition-colors">
        {{ $t('home.editTemplate') }}
      </NuxtLink>
    </div>
    
    <!-- Daily Prompt — placeholder only, excluded from layout for now -->
    <!-- <HomePageDailyPrompt /> -->

    <!-- Therapy Homework (shows only when pending items exist) -->
    <ToolkitHomeworkCard
      v-if="pendingHomework.length > 0"
      :pending-items="pendingHomework"
      @toggle="toolkitStore.toggleHomework"
    />
    
    <!-- Journal Entries Section -->
    <div class="px-4">
      <h3 class="text-xs font-semibold text-gray-500 tracking-wide uppercase mb-4 text-center">
        {{ $t('home.yourEntries') }}
      </h3>
      <HomePageLatestEntries :date="selectedDate" />
    </div>
    
    <!-- Floating Action Button -->
    <HomePageFloatingActionButton />

    <!-- Date Picker Modal -->
    <HomePageDatePickerModal v-model:open="showDatePicker" />
  </div>
</template>

<script setup lang="ts">
import { useToolkitStore } from "~/stores/stores/therapy_toolkit_store";
import { useHomeDate } from '~/composables/useHomeDate';

const toolkitStore = useToolkitStore();
const { selectedDate } = useHomeDate();
const showDatePicker = ref(false);

const pendingHomework = computed(() => toolkitStore.pendingHomework);

onMounted(async () => {
  if (toolkitStore.homeworkItems.length === 0) {
    await toolkitStore.loadFromLocal();
  }
});
</script>
