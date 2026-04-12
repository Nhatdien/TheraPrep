<template>
  <div class="flex flex-col h-full">
    <h2 class="text-2xl font-bold mb-2 text-center text-highlighted">
      {{ displayQuestion }}
    </h2>
    <p v-if="displayContent" class="text-sm text-muted mb-8 text-center leading-relaxed">
      {{ displayContent }}
    </p>

    <!-- Single-select: large contrast cards (2-column for 2 options, stacked for 3+) -->
    <div
      v-if="mode === 'single'"
      class="flex flex-col gap-3"
      :class="{ 'sm:grid sm:grid-cols-2': options.length <= 4 }"
    >
      <button
        v-for="option in options"
        :key="option.id"
        @click="selectSingle(option.id)"
        class="choice-card"
        :class="selected.has(option.id) ? 'choice-card--active' : 'choice-card--inactive'"
      >
        <span class="font-semibold text-base">{{ getOptionLabel(option) }}</span>
        <span v-if="getOptionDescription(option)" class="text-xs mt-1 opacity-80">
          {{ getOptionDescription(option) }}
        </span>
      </button>
    </div>

    <!-- Multi-select: stacked rectangular options -->
    <div v-else class="flex flex-col gap-3">
      <button
        v-for="option in options"
        :key="option.id"
        @click="toggleMulti(option.id)"
        class="choice-card"
        :class="selected.has(option.id) ? 'choice-card--active' : 'choice-card--inactive'"
      >
        <div class="flex items-center gap-3">
          <div
            class="w-5 h-5 rounded border-2 shrink-0 flex items-center justify-center transition-colors duration-150"
            :class="selected.has(option.id)
              ? 'border-[rgb(var(--ui-primary))] bg-[rgb(var(--ui-primary))]'
              : 'border-[rgb(var(--ui-border))]'"
          >
            <svg v-if="selected.has(option.id)" class="w-3 h-3 text-[rgb(var(--ui-bg))]" viewBox="0 0 12 12" fill="none">
              <path d="M2 6l3 3 5-5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </div>
          <div class="flex flex-col items-start">
            <span class="font-semibold text-base">{{ getOptionLabel(option) }}</span>
            <span v-if="getOptionDescription(option)" class="text-xs mt-0.5 opacity-80">
              {{ getOptionDescription(option) }}
            </span>
          </div>
        </div>
      </button>
    </div>

    <!-- Selection summary -->
    <p v-if="selected.size > 0" class="text-xs text-dimmed mt-4 text-center">
      {{ selected.size }} {{ selected.size === 1 ? 'selected' : 'selected' }}
    </p>
  </div>
</template>

<script setup lang="ts">
import type { QuestionnaireOption } from '~/types/user_journal';
import { userJournalStore } from '~/stores/stores/user_journal';

const props = defineProps({
  content: {
    type: Object,
    required: true,
  },
  currentIndex: {
    type: Number,
    required: true,
  },
  index: {
    type: Number,
    required: true,
  },
});

const { locale } = useI18n();
const store = userJournalStore();

const mode = computed(() => props.content?.mode || 'single');
const options = computed<QuestionnaireOption[]>(() => props.content?.options || []);
const selected = ref<Set<string>>(new Set());

const displayQuestion = computed(() => {
  if (locale.value === 'vi' && props.content?.question_vi) return props.content.question_vi;
  return props.content?.question || props.content?.title || '';
});

const displayContent = computed(() => {
  if (locale.value === 'vi' && props.content?.content_vi) return props.content.content_vi;
  return props.content?.content || '';
});

const getOptionLabel = (option: QuestionnaireOption) => {
  if (locale.value === 'vi' && option.label_vi) return option.label_vi;
  return option.label;
};

const getOptionDescription = (option: QuestionnaireOption) => {
  if (locale.value === 'vi' && option.description_vi) return option.description_vi;
  return option.description;
};

const selectSingle = (id: string) => {
  selected.value = new Set([id]);
  saveSelection();
};

const toggleMulti = (id: string) => {
  const next = new Set(selected.value);
  if (next.has(id)) {
    next.delete(id);
  } else {
    next.add(id);
  }
  selected.value = next;
  saveSelection();
};

const saveSelection = () => {
  const selectedLabels = options.value
    .filter(o => selected.value.has(o.id))
    .map(o => getOptionLabel(o))
    .join(', ');

  store.updateCurrentWritingContent(
    `questionnaire_${props.index}`,
    selectedLabels
  );
};
</script>

<style scoped>
.choice-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 1.25rem 1rem;
  border-radius: 1rem;
  border: 2px solid transparent;
  cursor: pointer;
  transition: all 200ms ease;
  text-align: center;
  min-height: 4rem;
}

.choice-card--inactive {
  border-color: rgb(var(--ui-border));
  background: rgb(var(--ui-bg-elevated));
  color: rgb(var(--ui-text-muted));
}

.choice-card--inactive:hover {
  border-color: rgb(var(--ui-border-accented));
  background: rgb(var(--ui-bg-accented));
}

.choice-card--active {
  border-color: rgb(var(--ui-primary));
  background: rgb(var(--ui-primary) / 0.15);
  color: rgb(var(--ui-text-highlighted));
  box-shadow: 0 0 0 1px rgb(var(--ui-primary) / 0.3), 0 0 12px rgb(var(--ui-primary) / 0.15);
}
</style>
