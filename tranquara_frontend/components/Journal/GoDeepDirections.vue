<template>
  <div class="inline-block">
    <!-- Mobile: Bottom Sheet Drawer -->
    <USlideover
      v-if="isMobile"
      v-model:open="isOpen"
      :title="$t('goDeeper.title')"
      :description="$t('goDeeper.subtitle')"
      :overlay="true"
    >
      <UButton
        color="primary"
        variant="soft"
        trailing-icon="i-heroicons-chevron-down-20-solid"
        :loading="loading"
        :disabled="disabled"
      >
        <span class="flex items-center gap-2">
          <span>{{ buttonLabel }}</span>
        </span>
      </UButton>

      <template #body>
        <div class="flex flex-col gap-3 p-4">
          <button
            v-for="dir in directions"
            :key="dir.value"
            class="flex items-center gap-4 px-4 py-4 rounded-xl border border-default bg-elevated text-left w-full transition-all duration-200 ease-out hover:border-primary hover:bg-primary/5 hover:-translate-y-0.5 hover:shadow-sm active:translate-y-0"
            @click="selectDirection(dir.value)"
          >
            <div class="flex-shrink-0 text-primary">
              <IconWhy v-if="dir.value === 'why'" :size="28" :active="true" />
              <IconEmotions v-else-if="dir.value === 'emotions'" :size="28" :active="true" />
              <IconPatterns v-else-if="dir.value === 'patterns'" :size="28" :active="true" />
              <IconChallenge v-else-if="dir.value === 'challenge'" :size="28" :active="true" />
              <IconGrowth v-else-if="dir.value === 'growth'" :size="28" :active="true" />
            </div>
            <div class="flex-1 flex flex-col gap-1 min-w-0">
              <div class="text-base font-semibold text-default">{{ $t(`goDeeper.directions.${dir.value}.label`) }}</div>
              <div class="text-sm text-muted leading-snug">{{ $t(`goDeeper.directions.${dir.value}.description`) }}</div>
            </div>
          </button>
        </div>
      </template>
    </USlideover>

    <!-- Desktop: Dropdown Menu -->
    <UDropdownMenu
      v-else
      :items="dropdownItems"
    >
      <UButton
        color="primary"
        variant="soft"
        trailing-icon="i-heroicons-chevron-down-20-solid"
        :loading="loading"
        :disabled="disabled"
      >
        <span class="flex items-center gap-2">
          <span>{{ buttonLabel }}</span>
        </span>
      </UButton>
    </UDropdownMenu>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, nextTick } from 'vue';
import IconWhy from '~/components/Icons/IconWhy.vue';
import IconEmotions from '~/components/Icons/IconEmotions.vue';
import IconPatterns from '~/components/Icons/IconPatterns.vue';
import IconChallenge from '~/components/Icons/IconChallenge.vue';
import IconGrowth from '~/components/Icons/IconGrowth.vue';

// Define props
const props = defineProps<{
  loading?: boolean;
  disabled?: boolean;
  modelValue?: boolean;
}>();

// Define emits
const emit = defineEmits<{
  (e: 'select', direction: string): void;
  (e: 'update:modelValue', value: boolean): void;
}>();

// Reactive state
const isOpen = ref(false);

// Watch for prop changes
watch(() => props.modelValue, (newVal) => {
  if (newVal !== undefined) {
    isOpen.value = newVal;
  }
});

// Watch for internal changes
watch(isOpen, (newVal) => {
  emit('update:modelValue', newVal);
});

// Detect mobile
const isMobile = computed(() => {
  if (process.client) {
    return window.innerWidth < 768;
  }
  return false;
});

// Button label
const { t } = useI18n();

const buttonLabel = computed(() => {
  return props.loading ? t('goDeeper.thinking') : t('goDeeper.button');
});

// Direction options
const directions = [
  { value: 'why', icon: 'i-lucide-lightbulb' },
  { value: 'emotions', icon: 'i-lucide-heart' },
  { value: 'patterns', icon: 'i-lucide-repeat' },
  { value: 'challenge', icon: 'i-lucide-puzzle' },
  { value: 'growth', icon: 'i-lucide-sprout' },
];

// Dropdown items for desktop
const dropdownItems = computed(() => [
  directions.map((dir) => ({
    label: t(`goDeeper.directions.${dir.value}.label`),
    icon: dir.icon,
    onSelect: () => selectDirection(dir.value),
  })),
]);

// Handle direction selection
function selectDirection(direction: string) {
  emit('select', direction);
  // Delay closing so parent loading state has time to render before
  // the slideover (and its trigger button) is unmounted
  nextTick(() => {
    isOpen.value = false;
  });
}
</script>
