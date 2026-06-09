<template>
  <section class="px-4 py-6 pb-20 lg:pb-0">
    <!-- Desktop Breadcrumbs -->
    <DesktopBreadcrumb :items="breadcrumbs" />

    <!-- Header -->
    <div class="flex items-center gap-3 mb-6">
      <button @click="navigateTo('/toolkit')" class="text-muted hover:text-highlighted transition-colors lg:hidden">
        <ChevronLeft class="w-5 h-5" />
      </button>
      <div>
        <h1 class="text-xl font-bold lg:text-2xl">{{ $t('toolkit.prepPack.title') }}</h1>
        <p class="text-muted text-xs mt-0.5">{{ $t('toolkit.prepPack.description') }}</p>
      </div>
    </div>

    <!-- Generate Section -->
    <div class="p-5 rounded-xl border border-default bg-elevated mb-6">
      <h2 class="text-sm font-medium mb-3">{{ $t('toolkit.prepPack.new') }}</h2>

      <!-- Date range selector -->
      <p class="text-xs text-muted mb-2">{{ $t('toolkit.prepPack.selectRange') }}</p>
      <div class="flex gap-2 mb-4">
        <button
          v-for="option in rangeOptions"
          :key="option.days"
          @click="selectPreset(option.days)"
          class="flex-1 py-2 px-3 rounded-lg text-xs font-medium border transition-colors"
          :class="!isCustomMode && selectedDays === option.days
            ? 'border-default bg-elevated text-highlighted'
            : 'border-default bg-muted text-muted hover:border-accented'"
        >
          {{ option.label }}
        </button>
        <!-- Custom option -->
        <button
          @click="toggleCustomMode"
          class="flex-1 py-2 px-3 rounded-lg text-xs font-medium border transition-colors"
          :class="isCustomMode
            ? 'border-default bg-elevated text-highlighted'
            : 'border-default bg-muted text-muted hover:border-accented'"
        >
          {{ $t('toolkit.prepPack.custom') }}
        </button>
      </div>

      <!-- Custom date picker -->
      <div v-if="isCustomMode" class="mb-4 p-4 rounded-lg bg-muted border border-default">
        <UCalendar
          :model-value="calendarRange"
          @update:model-value="onCalendarRangeChange"
          :max-date="todayDate"
          :min-date="minDate"
          range
          class="mx-auto"
        />

        <!-- Selected range display -->
        <div v-if="customStartDate && customEndDate" class="mt-3 flex items-center justify-between text-xs">
          <span class="text-muted">
            {{ formatPickerDate(customStartDate) }} – {{ formatPickerDate(customEndDate) }}
            <span class="text-dimmed ml-1">({{ daysInRange }}d)</span>
          </span>
        </div>

        <!-- Validation feedback -->
        <div class="mt-3 text-xs space-y-1">
          <div v-if="journalCountInRange >= 0" class="flex items-center gap-1" :class="journalCountInRange >= 3 ? 'text-green-400' : 'text-amber-400'">
            <Icon name="i-lucide-info" class="w-3 h-3" />
            <span>{{ $t('toolkit.prepPack.journalsFound', { count: journalCountInRange }) }}</span>
          </div>
          <div v-if="dateRangeError" class="flex items-center gap-1 text-red-400">
            <Icon name="i-lucide-alert-circle" class="w-3 h-3" />
            <span>{{ dateRangeError }}</span>
          </div>
        </div>
      </div>

      <!-- Generate button -->
      <UButton
        variant="soft"
        color="neutral"
        size="lg"
        class="w-full"
        :disabled="!hasJournals || toolkitStore.isGeneratingPrepPack"
        :loading="toolkitStore.isGeneratingPrepPack"
        @click="handleGenerate"
      >
        {{ toolkitStore.isGeneratingPrepPack
          ? $t('toolkit.prepPack.generating')
          : $t('toolkit.prepPack.generate') }}
      </UButton>

      <p v-if="!hasJournals" class="text-xs text-dimmed mt-2 text-center">
        {{ $t('toolkit.prepPack.noJournals') }}
      </p>

      <p v-if="toolkitStore.error" class="text-xs text-red-400 mt-2 text-center">
        {{ $t('toolkit.prepPack.errorGenerate') }}
      </p>
    </div>

    <!-- Past Prep Packs -->
    <div v-if="toolkitStore.prepPacks.length > 0">
      <h2 class="text-sm text-muted tracking-[0.2em] uppercase mb-3">
        {{ $t('toolkit.prepPack.pastPacks') }}
      </h2>

      <div class="space-y-2">
        <div
          v-for="pack in toolkitStore.prepPacks"
          :key="pack.id"
          class="flex items-center justify-between px-4 py-3 rounded-xl border border-muted bg-muted cursor-pointer active:bg-accented transition-colors"
          @click="navigateTo(`/toolkit/prep-pack/${pack.id}`)"
        >
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium">{{ formatDateRange(pack.date_range_start, pack.date_range_end) }}</p>
            <div class="flex items-center gap-2 mt-0.5">
              <span class="text-xs text-dimmed">
                {{ $t('toolkit.prepPack.journalsAnalyzed', { count: pack.journal_count }) }}
              </span>
              <span class="text-xs text-toned">·</span>
              <span class="text-xs text-dimmed">{{ formatDate(pack.created_at) }}</span>
            </div>
          </div>
          <div class="flex items-center gap-2 shrink-0">
            <button
              class="text-toned hover:text-red-400 transition-colors"
              @click.stop="handleDelete(pack.id)"
            >
              <Trash2 class="w-4 h-4" />
            </button>
            <Icon name="i-lucide-chevron-right" class="w-4 h-4 text-toned" />
          </div>
        </div>
      </div>
    </div>

    <!-- Empty state -->
    <div v-else class="text-center py-12">
      <Sparkles class="w-10 h-10 text-toned mx-auto mb-3" />
      <p class="text-dimmed text-sm">{{ $t('toolkit.prepPack.description') }}</p>
    </div>
  </section>
</template>

<script lang="ts" setup>
import type { BreadcrumbItem } from '@nuxt/ui'
import { ChevronLeft, Trash2, Sparkles } from "lucide-vue-next";
import { userJournalStore } from "~/stores/stores/user_journal";
import { useToolkitStore } from "~/stores/stores/therapy_toolkit_store";
import { CalendarDate } from '@internationalized/date';
import { useAuthStore } from "~/stores/stores/auth_store";
import JournalsRepository from "~/services/sqlite/journals_repository";
import DesktopBreadcrumb from '~/components/Common/DesktopBreadcrumb.vue';

const { t } = useI18n();
const { dateLocale } = useLocalizedDate();
const journalStore = userJournalStore();
const toolkitStore = useToolkitStore();

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  { label: t('nav.toolkit'), icon: 'i-lucide-heart-handshake', to: '/toolkit' },
  { label: t('toolkit.prepPack.title') },
])

// Custom mode state
const selectedDays = ref(7);
const isCustomMode = ref(false);
const customStartDate = ref('');
const customEndDate = ref('');
const today = new Date().toISOString().split('T')[0];

// Date bounds for UCalendar (CalendarDate instances)
const todayNative = new Date();
const todayDate = new CalendarDate(todayNative.getFullYear(), todayNative.getMonth() + 1, todayNative.getDate());
const minDateNative = new Date();
minDateNative.setDate(minDateNative.getDate() - 90);
const minDate = new CalendarDate(minDateNative.getFullYear(), minDateNative.getMonth() + 1, minDateNative.getDate());

// Reactive journal count (fetched from SQLite, not in-memory)
const journalCountInRange = ref(-1);

// Helper: convert "YYYY-MM-DD" to CalendarDate for UCalendar
function isoToCalendarDate(iso: string): CalendarDate {
  const [y, m, d] = iso.split('-').map(Number);
  return new CalendarDate(y, m, d);
}

// Computed: UCalendar range model (DateRange { start, end })
const calendarRange = computed(() => {
  if (customStartDate.value && customEndDate.value) {
    return {
      start: isoToCalendarDate(customStartDate.value),
      end: isoToCalendarDate(customEndDate.value),
    };
  }
  return undefined;
});

// Computed: number of days in the selected range
const daysInRange = computed(() => {
  if (!customStartDate.value || !customEndDate.value) return 0;
  const start = new Date(customStartDate.value);
  const end = new Date(customEndDate.value);
  return Math.ceil(Math.abs(end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)) + 1;
});

// Handler: UCalendar range change
const onCalendarRangeChange = (value: any) => {
  if (value?.start && value?.end) {
    customStartDate.value = String(value.start);
    customEndDate.value = String(value.end);
  } else if (value?.start) {
    customStartDate.value = String(value.start);
    customEndDate.value = '';
  } else {
    customStartDate.value = '';
    customEndDate.value = '';
  }
};

// Helper: format date for display below the picker
const formatPickerDate = (dateStr: string): string => {
  return new Date(dateStr).toLocaleDateString(dateLocale.value, {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
};

// Fetch journal count from SQLite (performant for large datasets)
async function fetchJournalCount() {
  if (!isCustomMode.value || !customStartDate.value || !customEndDate.value) {
    journalCountInRange.value = -1;
    return;
  }
  try {
    const authStore = useAuthStore();
    const userId = authStore.getUserUUID;
    if (!userId) { journalCountInRange.value = -1; return; }
    journalCountInRange.value = await JournalsRepository.countByDateRange(
      userId,
      customStartDate.value,
      customEndDate.value,
    );
  } catch {
    journalCountInRange.value = -1;
  }
}

// Re-fetch count when custom dates change
watch([customStartDate, customEndDate], fetchJournalCount);

// Initialize custom dates to last 7 days
onMounted(() => {
  const end = new Date();
  const start = new Date();
  start.setDate(end.getDate() - 7);
  customStartDate.value = start.toISOString().split('T')[0];
  customEndDate.value = end.toISOString().split('T')[0];
});

const rangeOptions = computed(() => [
  { days: 7, label: t('toolkit.prepPack.last7Days') },
  { days: 14, label: t('toolkit.prepPack.last14Days') },
  { days: 30, label: t('toolkit.prepPack.last30Days') },
]);

const hasJournals = computed(() => journalStore.journals.length > 0);

// Computed: effective date range based on mode
const effectiveDateRange = computed(() => {
  if (isCustomMode.value && customStartDate.value && customEndDate.value) {
    let start = new Date(customStartDate.value);
    let end = new Date(customEndDate.value);
    
    // Swap if start > end
    if (start > end) {
      [start, end] = [end, start];
    }
    
    return {
      start: start.toISOString().split('T')[0],
      end: end.toISOString().split('T')[0],
    };
  }
  
  const end = new Date();
  const start = new Date();
  start.setDate(end.getDate() - selectedDays.value);
  return {
    start: start.toISOString().split('T')[0],
    end: end.toISOString().split('T')[0],
  };
});

// Computed: date range validation
const dateRangeError = computed(() => {
  if (!isCustomMode.value) return null;
  
  const { start, end } = effectiveDateRange.value;
  
  if (!start || !end) return null;
  
  const startDate = new Date(start);
  const endDate = new Date(end);
  const daysDiff = Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24));
  
  if (daysDiff > 90) {
    return t('toolkit.prepPack.errorRangeTooLarge');
  }
  
  if (daysDiff < 0) {
    return t('toolkit.prepPack.errorInvalidRange');
  }
  
  return null;
});

// Actions
const selectPreset = (days: number) => {
  isCustomMode.value = false;
  selectedDays.value = days;
};

const toggleCustomMode = () => {
  isCustomMode.value = !isCustomMode.value;
  if (isCustomMode.value) {
    // Initialize with last 7 days when entering custom mode
    const end = new Date();
    const start = new Date();
    start.setDate(end.getDate() - 7);
    customStartDate.value = start.toISOString().split('T')[0];
    customEndDate.value = end.toISOString().split('T')[0];
  }
};

const handleGenerate = async () => {
  const { start, end } = effectiveDateRange.value;

  const pack = await toolkitStore.generatePrepPack(start, end);

  if (pack) {
    navigateTo(`/toolkit/prep-pack/${pack.id}`);
  }
};

const handleDelete = async (id: string) => {
  if (confirm(t('toolkit.prepPack.deleteConfirm'))) {
    await toolkitStore.deletePrepPack(id);
  }
};

const formatDate = (date?: string): string => {
  if (!date) return '';
  return new Date(date).toLocaleDateString(dateLocale.value, {
    month: 'short',
    day: 'numeric',
  });
};

const formatDateRange = (start: string, end: string): string => {
  const s = new Date(start);
  const e = new Date(end);
  const opts: Intl.DateTimeFormatOptions = { month: 'short', day: 'numeric' };
  return `${s.toLocaleDateString(dateLocale.value, opts)} – ${e.toLocaleDateString(dateLocale.value, opts)}`;
};

onMounted(async () => {
  await toolkitStore.loadFromLocal();
});
</script>
