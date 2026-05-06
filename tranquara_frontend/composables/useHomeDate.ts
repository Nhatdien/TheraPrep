/**
 * useHomeDate — shared state for the home screen selected date.
 *
 * Used by index.vue, DateHeader.vue, LatestEntries.vue, DailyCheckIn.vue
 * and DatePickerModal.vue so all components stay in sync.
 */

const selectedDate = ref<string>(todayISO());

function todayISO(): string {
  const d = new Date();
  return d.toISOString().split('T')[0]; // "YYYY-MM-DD"
}

export function useHomeDate() {
  const isToday = computed<boolean>(
    () => selectedDate.value === todayISO()
  );

  function setDate(date: string) {
    selectedDate.value = date;
  }

  function resetToToday() {
    selectedDate.value = todayISO();
  }

  return { selectedDate: readonly(selectedDate), isToday, setDate, resetToToday };
}
