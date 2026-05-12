<template>
  <section class="space-y-3 pb-6 md:grid md:grid-cols-2 md:gap-4 md:space-y-0 xl:grid-cols-3">
    <!-- Sync Status Banner -->
    <SyncStatusBanner
      :is-online="userJournalStore().isOnline"
      :is-syncing="userJournalStore().isSyncing"
      :pending-count="pendingSyncCount"
      :show-sync-button="true"
      @sync="triggerSync"
      class="md:col-span-2 xl:col-span-3"
    />

    <!-- Featured First Entry (spans 2 cols on desktop) -->
    <div
      v-if="userJournalStore()?.journals?.length > 0"
      @click="() => openEntry(userJournalStore().journals[0])"
      class="bg-muted rounded-xl p-4 cursor-pointer hover:bg-accented hover:shadow-sm transition-all border relative lg:col-span-2 lg:p-6 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/50"
      tabindex="0"
      @keydown.enter="() => openEntry(userJournalStore().journals[0])"
    >
      <!-- Sync Status Badge (top right) -->
      <div class="absolute top-3 right-3 lg:top-5 lg:right-5">
        <SyncBadge
          :needs-sync="userJournalStore().journals[0].needs_sync"
          :syncing="userJournalStore().isSyncing"
        />
      </div>

      <!-- Header: Category & Time -->
      <div class="flex justify-between items-start mb-3 pr-16">
        <span class="text-xs text-muted uppercase tracking-wide font-semibold">
          {{ $t('entries.reflection') }}
        </span>
        <span class="text-xs text-muted">
          {{ formatTime(userJournalStore().journals[0].created_at) }}
        </span>
      </div>

      <!-- Title -->
      <h3 class="font-semibold text-highlighted mb-3 text-lg lg:text-xl">
        {{ userJournalStore().journals[0].title }}
      </h3>

      <!-- Mood Tag + Sleep Tag + Word Count (desktop) -->
      <div class="flex flex-wrap gap-2 mb-3">
        <span v-if="userJournalStore().journals[0].mood_label" class="px-3 py-1 bg-accented rounded-full text-xs text-default flex items-center gap-1">
          <Icon :name="getMoodIcon(userJournalStore().journals[0].mood_score)" class="w-3 h-3" />
          {{ userJournalStore().journals[0].mood_score ? $t(`journal.moodLabels.${userJournalStore().journals[0].mood_score}`) : userJournalStore().journals[0].mood_label }}
        </span>
        <span
          v-if="userJournalStore().journals[0].sleep_score !== null && userJournalStore().journals[0].sleep_score !== undefined"
          class="px-3 py-1 bg-sky-100 dark:bg-sky-900/30 text-sky-600 dark:text-sky-400 rounded-full text-xs flex items-center gap-1">
          <Icon :name="getSleepInfo(userJournalStore().journals[0].sleep_score).icon" class="w-3 h-3" />
          {{ $t(`journal.sleepLabels.${getSleepInfo(userJournalStore().journals[0].sleep_score).level}`) }}
        </span>
        <span class="hidden lg:flex px-3 py-1 bg-accented rounded-full text-xs text-dimmed items-center gap-1">
          {{ getWordCount(userJournalStore().journals[0].content) }} {{ $t('entries.words', getWordCount(userJournalStore().journals[0].content)) }}
        </span>
      </div>

      <!-- Content Preview (longer on desktop) -->
      <div class="text-sm text-muted line-clamp-3 lg:line-clamp-4" v-html="getContentPreview(userJournalStore().journals[0].content)"></div>
    </div>

    <!-- Remaining Entry Cards -->
    <div 
      v-for="journal in userJournalStore()?.journals?.slice(1)" 
      :key="journal.id"
      @click="() => openEntry(journal)"
      class="bg-muted rounded-xl p-4 cursor-pointer hover:bg-accented hover:shadow-sm transition-all border relative focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/50"
      tabindex="0"
      @keydown.enter="() => openEntry(journal)"
    >
      <!-- Sync Status Badge (top right) -->
      <div class="absolute top-3 right-3">
        <SyncBadge 
          :needs-sync="journal.needs_sync" 
          :syncing="userJournalStore().isSyncing"
        />
      </div>

      <!-- Header: Category & Time -->
      <div class="flex justify-between items-start mb-3 pr-16">
        <span class="text-xs text-muted uppercase tracking-wide font-semibold">
          {{ $t('entries.reflection') }}
        </span>
        <span class="text-xs text-muted">
          {{ formatTime(journal.created_at) }}
        </span>
      </div>

      <!-- Title -->
      <h3 class="font-semibold text-highlighted mb-3 text-lg">
        {{ journal.title }}
      </h3>

      <!-- Mood + Sleep Tags -->
      <div class="flex flex-wrap gap-2 mb-3">
        <span v-if="journal.mood_label" class="px-3 py-1 bg-accented rounded-full text-xs text-default flex items-center gap-1">
          <Icon :name="getMoodIcon(journal.mood_score)" class="w-3 h-3" />
          {{ journal.mood_score ? $t(`journal.moodLabels.${journal.mood_score}`) : journal.mood_label }}
        </span>
        <span
          v-if="journal.sleep_score !== null && journal.sleep_score !== undefined"
          class="px-3 py-1 bg-sky-100 dark:bg-sky-900/30 text-sky-600 dark:text-sky-400 rounded-full text-xs flex items-center gap-1">
          <Icon :name="getSleepInfo(journal.sleep_score).icon" class="w-3 h-3" />
          {{ $t(`journal.sleepLabels.${getSleepInfo(journal.sleep_score).level}`) }}
        </span>
      </div>

      <!-- Content Preview (first few lines) -->
      <div class="text-sm text-muted line-clamp-3" v-html="getContentPreview(journal.content)"></div>
    </div>

    <!-- Empty State -->
    <!-- Empty State -->
    <div v-if="!userJournalStore().journals || userJournalStore().journals.length === 0" class="text-center py-16 md:col-span-2 xl:col-span-3">
      <div class="w-16 h-16 rounded-full bg-muted flex items-center justify-center mx-auto mb-4">
        <Icon name="i-lucide-pen-line" class="w-8 h-8 text-dimmed" />
      </div>
      <p class="text-highlighted font-medium mb-1">{{ $t('entries.noEntries') }}</p>
      <p class="text-muted text-sm mb-4 max-w-xs mx-auto">{{ $t('entries.emptyPrompt') }}</p>
      <UButton @click="navigateTo('/journaling')" variant="outline">
        {{ $t('entries.startFirst') }}
      </UButton>
    </div>

    <!-- See All Button -->
    <div v-if="userJournalStore().journals && userJournalStore().journals.length > 0" class="text-center pt-4 md:col-span-2 xl:col-span-3">
      <UButton 
        variant="ghost" 
        @click="navigateTo('/history')"
        class="text-muted hover:text-default"
      >
        {{ $t('entries.seeAll') }}
        <template #trailing>
          <ChevronRight class="w-4 h-4" />
        </template>
      </UButton>
    </div>
  </section>
</template>

<script setup lang="ts">
import { CreateJournalRequest, LocalJournal } from '~/types/user_journal';
import { ChevronRight } from 'lucide-vue-next';
import { useAuthStore } from '~/stores/stores/auth_store';

const authStore = useAuthStore();

// Computed property for pending sync count
const pendingSyncCount = computed(() => userJournalStore().pendingSyncCount);

// Trigger manual sync
const triggerSync = async () => {
  try {
    await userJournalStore().syncWithServer();
  } catch (error) {
    console.error('[LatestEntries] Error syncing:', error);
  }
};

const openEntry = (journal: LocalJournal) => {
  userJournalStore().currentJournal = journal;
  navigateTo(`/learn_and_prepare/journal/${journal.id}`);
};

const formatTime = (dateString: string) => {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true });
};

const getContentPreview = (content: string) => {
  if (!content) return '';

  console.log(content);
  
  // Strip HTML tags and get first 150 characters
  const stripped = content;
  return stripped.length > 150 ? stripped.substring(0, 150) + '...' : stripped;
};

const getMoodIcon = (score: number | null | undefined) => {
  if (!score) return 'i-lucide-smile';
  if (score <= 2) return 'i-lucide-cloud-rain';
  if (score <= 4) return 'i-lucide-cloud';
  if (score <= 6) return 'i-lucide-meh';
  if (score <= 8) return 'i-lucide-smile';
  return 'i-lucide-sun';
};

const getSleepInfo = (score: number | null | undefined) => {
  const s = score ?? 0;
  if (s <= 20) return { level: 'exhausted', icon: 'i-lucide-cloud-fog' };
  if (s <= 40) return { level: 'tired',     icon: 'i-lucide-moon' };
  if (s <= 60) return { level: 'fair',      icon: 'i-lucide-cloud-moon' };
  if (s <= 80) return { level: 'rested',    icon: 'i-lucide-star' };
  return           { level: 'refreshed',  icon: 'i-lucide-sparkles' };
};

const getWordCount = (content: string) => {
  if (!content) return 0;
  const text = content.replace(/<[^>]*>/g, '').trim();
  return text ? text.split(/\s+/).length : 0;
};

onMounted(async () => {
  try {
    if (!authStore.isAuthenticated) return;
    if (!userJournalStore().isInitialized) {
      await userJournalStore().initializeDatabase();
    }
    await userJournalStore().getJournals();
  } catch (error) {
    console.error('[LatestEntries] Error loading journals:', error);
  }
});
</script>
