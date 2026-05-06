<template>
  <UModal :open="open" @update:open="$emit('update:open', $event)">
    <template #content>
      <div class="p-4 select-none">
        <h2 class="text-base font-semibold text-center mb-4">{{ $t('datePicker.title') }}</h2>

        <!-- Month navigation -->
        <div class="flex items-center justify-between mb-3">
          <button class="p-2 rounded-full hover:bg-muted" @click="prevMonth">
            <ChevronLeft class="w-5 h-5" />
          </button>
          <span class="font-semibold capitalize">{{ monthLabel }}</span>
          <button
            class="p-2 rounded-full hover:bg-muted"
            :disabled="isCurrentMonthOrFuture"
            :class="{ 'opacity-30 cursor-not-allowed': isCurrentMonthOrFuture }"
            @click="nextMonth">
            <ChevronRight class="w-5 h-5" />
          </button>
        </div>

        <!-- Day-of-week headers -->
        <div class="grid grid-cols-7 mb-1">
          <span
            v-for="d in dayNames"
            :key="d"
            class="text-center text-xs font-semibold text-muted py-1">
            {{ d }}
          </span>
        </div>

        <!-- Calendar grid -->
        <div class="grid grid-cols-7 gap-y-1">
          <!-- Leading empty cells -->
          <div v-for="_ in leadingBlanks" :key="'b' + _" />

          <!-- Day cells -->
          <button
            v-for="day in daysInMonth"
            :key="day"
            class="relative flex flex-col items-center justify-center h-9 w-full rounded-full transition-colors"
            :class="dayCellClass(day)"
            :disabled="isFutureDay(day) || isTooFarBack(day)"
            @click="selectDay(day)"
          >
            <span class="text-sm">{{ day }}</span>
            <!-- Dot indicator for days with journal entries -->
            <span
              v-if="hasEntry(day)"
              class="absolute bottom-1 w-1 h-1 rounded-full"
              :class="isSelected(day) ? 'bg-white' : 'bg-primary'"
            />
          </button>
        </div>

        <!-- Today button -->
        <div class="mt-4 text-center">
          <UButton variant="ghost" size="sm" :disabled="isToday" @click="goToToday">
            {{ $t('datePicker.today') }}
          </UButton>
        </div>
      </div>
    </template>
  </UModal>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue';
import { ChevronLeft, ChevronRight } from 'lucide-vue-next';
import { useHomeDate } from '~/composables/useHomeDate';
import JournalsRepository from '~/services/sqlite/journals_repository';
import { useAuthStore } from '~/stores/stores/auth_store';

defineProps<{ open: boolean }>();
defineEmits<{ 'update:open': [value: boolean] }>();

const { selectedDate, isToday, setDate, resetToToday } = useHomeDate();

// The month being displayed — starts at the selected date's month
const viewYear = ref(new Date().getFullYear());
const viewMonth = ref(new Date().getMonth()); // 0-indexed

// Days that have at least one journal entry (loaded per viewed month)
const entryDays = ref<Set<number>>(new Set());

const { locale } = useI18n();
const dayNames = computed(() => {
  const base = new Date(2024, 0, 7); // Sunday
  return Array.from({ length: 7 }, (_, i) => {
    const d = new Date(base);
    d.setDate(7 + i);
    return d.toLocaleDateString(locale.value === 'vi' ? 'vi-VN' : 'en-US', { weekday: 'short' });
  });
});

const monthLabel = computed(() =>
  new Date(viewYear.value, viewMonth.value, 1).toLocaleDateString(
    locale.value === 'vi' ? 'vi-VN' : 'en-US',
    { month: 'long', year: 'numeric' }
  )
);

const daysInMonth = computed(() =>
  new Date(viewYear.value, viewMonth.value + 1, 0).getDate()
);

// First weekday of month (0=Sun)
const leadingBlanks = computed(() =>
  new Date(viewYear.value, viewMonth.value, 1).getDay()
);

const isCurrentMonthOrFuture = computed(() => {
  const now = new Date();
  return viewYear.value > now.getFullYear() ||
    (viewYear.value === now.getFullYear() && viewMonth.value >= now.getMonth());
});

const MAX_DAYS_BACK = 30;

function isFutureDay(day: number): boolean {
  const d = new Date(viewYear.value, viewMonth.value, day);
  return d > new Date();
}

function isTooFarBack(day: number): boolean {
  const d = new Date(viewYear.value, viewMonth.value, day);
  const cutoff = new Date();
  cutoff.setDate(cutoff.getDate() - MAX_DAYS_BACK);
  return d < cutoff;
}

function isSelected(day: number): boolean {
  return selectedDate.value === dayISO(day);
}

function hasEntry(day: number): boolean {
  return entryDays.value.has(day);
}

function dayCellClass(day: number) {
  const future = isFutureDay(day);
  const tooOld = isTooFarBack(day);
  if (future || tooOld) return 'opacity-30 cursor-not-allowed';
  if (isSelected(day)) return 'bg-primary text-white font-bold';
  const today = new Date();
  if (
    day === today.getDate() &&
    viewMonth.value === today.getMonth() &&
    viewYear.value === today.getFullYear()
  ) return 'ring-1 ring-primary text-primary font-semibold hover:bg-muted';
  return 'hover:bg-muted';
}

function dayISO(day: number): string {
  const m = String(viewMonth.value + 1).padStart(2, '0');
  const d = String(day).padStart(2, '0');
  return `${viewYear.value}-${m}-${d}`;
}

function selectDay(day: number) {
  if (isFutureDay(day) || isTooFarBack(day)) return;
  setDate(dayISO(day));
}

function goToToday() {
  resetToToday();
  const now = new Date();
  viewYear.value = now.getFullYear();
  viewMonth.value = now.getMonth();
}

function prevMonth() {
  if (viewMonth.value === 0) {
    viewMonth.value = 11;
    viewYear.value--;
  } else {
    viewMonth.value--;
  }
}

function nextMonth() {
  if (isCurrentMonthOrFuture.value) return;
  if (viewMonth.value === 11) {
    viewMonth.value = 0;
    viewYear.value++;
  } else {
    viewMonth.value++;
  }
}

async function loadEntryDays() {
  try {
    const authStore = useAuthStore();
    const userId = authStore.getUserUUID;
    if (!userId) return;
    const firstDay = `${viewYear.value}-${String(viewMonth.value + 1).padStart(2, '0')}-01`;
    const lastDay = `${viewYear.value}-${String(viewMonth.value + 1).padStart(2, '0')}-${String(daysInMonth.value).padStart(2, '0')}T23:59:59Z`;
    const result = await JournalsRepository.getWithFilter(userId, {
      startTime: firstDay,
      endTime: lastDay,
      pageSize: 200,
    });
    const days = new Set<number>();
    for (const j of result.journals) {
      const d = new Date(j.created_at);
      if (d.getMonth() === viewMonth.value && d.getFullYear() === viewYear.value) {
        days.add(d.getDate());
      }
    }
    entryDays.value = days;
  } catch {
    entryDays.value = new Set();
  }
}

// Re-load dots when month changes
watch([viewYear, viewMonth], loadEntryDays, { immediate: true });

// Sync view to selectedDate when modal opens
watch(() => selectedDate.value, (v) => {
  const d = new Date(v);
  viewYear.value = d.getFullYear();
  viewMonth.value = d.getMonth();
}, { immediate: true });
</script>
