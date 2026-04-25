<template>
  <section class="px-4 py-6 pb-20 lg:pb-0">
    <!-- Header -->
    <div class="mb-4">
      <h1 class="text-2xl font-bold lg:text-3xl">{{ $t('toolkit.title') }}</h1>
      <p class="text-muted text-sm mt-1">{{ $t('toolkit.subtitle') }}</p>
    </div>

    <!-- 3-Tab Layout -->
    <UTabs
      :items="tabs"
      :default-value="tabs[0].value"
      :content="false"
      v-model="activeTab"
      :ui="{
        list: 'mb-6',
      }"
    />

    <!-- ═══════════════ TAB: PREPARE ═══════════════ -->
    <div v-if="activeTab === 'prepare'">
      <!-- Preparation Journey -->
      <div class="mb-8">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-sm text-muted tracking-[0.2em] uppercase">
            {{ $t('toolkit.journey.title') }}
          </h2>
          <span v-if="overallProgress > 0" class="text-xs text-dimmed">
            {{ $t('toolkit.journey.overallProgress', { percent: overallProgress }) }}
          </span>
        </div>
        <div class="flex flex-col gap-3 md:grid md:grid-cols-2 xl:grid-cols-3">
          <ToolkitJourneyStepCard
            v-for="step in journeySteps"
            :key="step.collectionId"
            :step="step"
            :collection="getCollection(step.collectionId)"
            :completed-count="learnedStore.getCompletedCount(step.collectionId)"
            :total-count="getSlideGroupCount(step.collectionId)"
            @tap="navigateToCollection(step.collectionId)"
          />
        </div>
      </div>

      <!-- My Insights -->
      <div class="mb-8">
        <h2 class="text-sm text-muted tracking-[0.2em] uppercase mb-4">
          {{ $t('toolkit.prepPack.title') }}
        </h2>

        <!-- Has insights -->
        <div v-if="toolkitStore.latestPrepPack" class="p-5 rounded-xl border border-default bg-elevated">
          <p class="text-muted text-sm mb-3">{{ $t('toolkit.prepPack.description') }}</p>
          <div class="flex items-center justify-between mb-3">
            <span class="text-xs text-dimmed">
              {{ $t('toolkit.prepPack.lastGenerated') }}: {{ formatDate(toolkitStore.latestPrepPack.created_at) }}
            </span>
            <button
              class="text-xs text-muted hover:text-highlighted transition-colors underline"
              @click="navigateTo(`/toolkit/prep-pack/${toolkitStore.latestPrepPack.id}`)"
            >
              {{ $t('common.view') }}
            </button>
          </div>
          <UButton
            variant="soft"
            color="neutral"
            size="lg"
            class="w-full"
            @click="navigateTo('/toolkit/prep-pack')"
          >
            {{ $t('toolkit.prepPack.viewAll') }}
          </UButton>
        </div>

        <!-- Empty state -->
        <div v-else>
          <ToolkitEmptyState
            :illustration="IlluBrain"
            :message="$t('toolkit.emptyState.insights')"
            :cta-label="hasJournals ? $t('toolkit.prepPack.generate') : undefined"
            @action="navigateTo('/toolkit/prep-pack')"
          />
          <p v-if="!hasJournals" class="text-xs text-dimmed text-center -mt-4">
            {{ $t('toolkit.prepPack.noJournals') }}
          </p>
        </div>
      </div>
    </div>

    <!-- ═══════════════ TAB: TRACK ═══════════════ -->
    <div v-if="activeTab === 'track'">
      <!-- Session Tracker -->
      <div class="mb-8">
        <h2 class="text-sm text-muted tracking-[0.2em] uppercase mb-4">
          {{ $t('toolkit.session.title') }}
        </h2>

        <!-- Session countdown card -->
        <div v-if="toolkitStore.upcomingSession" class="p-5 rounded-xl border border-default bg-elevated mb-4">
          <div class="flex items-start justify-between mb-3">
            <div>
              <p class="text-lg font-semibold">{{ formatDate(toolkitStore.upcomingSession.session_date) }}</p>
              <p class="text-sm mt-0.5" :class="countdownClass">{{ countdownText }}</p>
            </div>
            <div class="flex items-center gap-2">
              <span class="text-xs px-2 py-0.5 rounded-full"
                :class="toolkitStore.upcomingSession.status === 'before_completed'
                  ? 'bg-green-900/30 text-green-400'
                  : 'bg-accented text-default'">
                {{ $t(`toolkit.session.status.${toolkitStore.upcomingSession.status === 'before_completed' ? 'beforeCompleted' : 'scheduled'}`) }}
              </span>
              <button
                class="text-toned hover:text-red-400 transition-colors"
                @click="confirmDeleteSession(toolkitStore.upcomingSession.id)"
              >
                <Trash2 class="w-4 h-4" />
              </button>
            </div>
          </div>

          <div class="flex gap-2">
            <UButton
              v-if="toolkitStore.upcomingSession.status === 'scheduled'"
              variant="soft"
              color="neutral"
              size="sm"
              class="flex-1"
              @click="navigateTo(`/toolkit/session/new?step=before&sessionId=${toolkitStore.upcomingSession.id}`)"
            >
              {{ $t('toolkit.session.prepare') }}
            </UButton>
            <UButton
              v-if="toolkitStore.upcomingSession.status === 'before_completed'"
              variant="soft"
              color="neutral"
              size="sm"
              class="flex-1"
              @click="navigateTo(`/toolkit/session/new?step=after&sessionId=${toolkitStore.upcomingSession.id}`)"
            >
              {{ $t('toolkit.session.logAfter') }}
            </UButton>
          </div>
        </div>

        <!-- No session — flow preview + schedule -->
        <div v-else class="rounded-xl border border-default bg-elevated overflow-hidden">
          <!-- Flow preview -->
          <div class="px-5 pt-5 pb-3">
            <p class="text-xs text-dimmed uppercase tracking-wider mb-3">{{ $t('toolkit.sessionFlow.title') }}</p>
            <div class="flex items-center justify-between mb-4">
              <div v-for="(step, i) in sessionFlowSteps" :key="step.key" class="flex items-center gap-1.5">
                <div class="flex flex-col items-center gap-1">
                  <div class="w-8 h-8 rounded-full bg-accented flex items-center justify-center">
                    <component :is="step.icon" class="w-4 h-4 text-muted" />
                  </div>
                  <span class="text-[10px] text-dimmed">{{ $t(step.labelKey) }}</span>
                </div>
                <Icon v-if="i < sessionFlowSteps.length - 1" name="i-lucide-chevron-right" class="w-3 h-3 text-toned mt-[-14px]" />
              </div>
            </div>
          </div>

          <!-- Schedule CTA -->
          <div class="border-t border-default p-5 text-center">
            <UButton
              variant="soft"
              color="neutral"
              @click="showSchedulePanel = !showSchedulePanel"
            >
              {{ $t('toolkit.session.schedule') }}
            </UButton>
          </div>

          <!-- Calendar panel -->
          <Transition name="slide-down">
            <div v-if="showSchedulePanel" class="border-t border-default px-5 pb-5 pt-4">
              <p class="text-sm text-muted mb-3">{{ $t('toolkit.session.scheduleTitle') }}</p>
              <div class="flex justify-center mb-3">
                <UCalendar v-model="calendarDate" class="mx-auto" />
              </div>
              <div class="flex gap-2">
                <UButton
                  variant="ghost"
                  color="neutral"
                  size="sm"
                  class="flex-1"
                  @click="showSchedulePanel = false"
                >
                  {{ $t('common.cancel') }}
                </UButton>
                <UButton
                  variant="soft"
                  color="neutral"
                  size="sm"
                  class="flex-1"
                  :disabled="!calendarDate"
                  @click="handleScheduleSession"
                >
                  {{ $t('toolkit.session.scheduleConfirm') }}
                </UButton>
              </div>
            </div>
          </Transition>
        </div>

        <!-- Past sessions -->
        <div v-if="toolkitStore.completedSessions.length > 0" class="mt-4">
          <h3 class="text-xs text-dimmed uppercase tracking-wider mb-2">
            {{ $t('toolkit.session.pastSessions') }}
          </h3>
          <div class="space-y-2">
            <div
              v-for="session in toolkitStore.completedSessions.slice(0, 5)"
              :key="session.id"
              class="flex items-center justify-between px-4 py-3 rounded-xl border border-muted bg-muted cursor-pointer active:bg-accented transition-colors"
              @click="navigateTo(`/toolkit/session/${session.id}`)"
            >
              <div>
                <span class="text-sm">{{ formatDate(session.session_date) }}</span>
                <div v-if="session.session_rating" class="flex gap-0.5 mt-0.5">
                  <span
                    v-for="star in 5"
                    :key="star"
                    class="text-xs"
                    :class="star <= session.session_rating ? 'text-yellow-400' : 'text-accented'"
                  >★</span>
                </div>
              </div>
              <div class="flex items-center gap-2">
                <span class="text-xs text-dimmed">{{ $t('toolkit.session.status.completed') }}</span>
                <Icon name="i-lucide-chevron-right" class="w-4 h-4 text-toned" />
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Homework -->
      <div class="mb-8">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-sm text-muted tracking-[0.2em] uppercase">
            {{ $t('toolkit.homework.title') }}
          </h2>
          <span v-if="toolkitStore.homeworkItems.length > 0" class="text-xs text-dimmed">
            {{ completedHomeworkCount }}/{{ toolkitStore.homeworkItems.length }}
          </span>
        </div>

        <!-- Add homework inline -->
        <div v-if="toolkitStore.upcomingSession" class="flex gap-2 mb-3">
          <UInput
            v-model="newHomeworkText"
            :placeholder="$t('toolkit.homework.addPlaceholder')"
            class="flex-1"
            size="sm"
            @keyup.enter="handleAddHomework"
          />
          <button
            @click="handleAddHomework"
            :disabled="!newHomeworkText.trim()"
            class="w-9 h-9 rounded-full bg-accented border border-default flex items-center justify-center text-base transition-colors shrink-0"
            :class="newHomeworkText.trim() ? 'hover:bg-muted text-highlighted' : 'text-toned cursor-not-allowed'"
          >
            +
          </button>
        </div>

        <!-- Pending items -->
        <div v-if="pendingHomework.length > 0" class="space-y-2">
          <div
            v-for="item in pendingHomework"
            :key="item.id"
            class="flex items-center gap-3 px-4 py-3 rounded-xl border border-muted bg-muted"
          >
            <button
              class="w-5 h-5 rounded border-2 border-accented shrink-0 transition-colors hover:border-muted"
              @click="toolkitStore.toggleHomework(item.id)"
            />
            <span class="text-sm flex-1">{{ item.content }}</span>
            <button
              class="text-toned hover:text-red-400 transition-colors shrink-0"
              @click="toolkitStore.deleteHomework(item.id)"
            >
              <X class="w-3.5 h-3.5" />
            </button>
          </div>
        </div>

        <!-- Completed items (collapsed) -->
        <div v-if="completedHomework.length > 0" class="mt-2">
          <button
            v-if="pendingHomework.length > 0"
            class="text-xs text-dimmed hover:text-muted mb-2 transition-colors"
            @click="showCompletedHomework = !showCompletedHomework"
          >
            {{ showCompletedHomework ? '▾' : '▸' }} {{ $t('toolkit.homework.completed') }} ({{ completedHomework.length }})
          </button>
          <div v-if="showCompletedHomework || pendingHomework.length === 0" class="space-y-2">
            <div
              v-for="item in completedHomework"
              :key="item.id"
              class="flex items-center gap-3 px-4 py-3 rounded-xl border border-muted/50 bg-muted"
            >
              <button
                class="w-5 h-5 rounded border-2 border-green-500 bg-green-500/20 flex items-center justify-center shrink-0 transition-colors"
                @click="toolkitStore.toggleHomework(item.id)"
              >
                <Icon name="i-lucide-check" class="w-3 h-3 text-green-400" />
              </button>
              <span class="text-sm flex-1 line-through text-dimmed">{{ item.content }}</span>
              <button
                class="text-toned hover:text-red-400 transition-colors shrink-0"
                @click="toolkitStore.deleteHomework(item.id)"
              >
                <X class="w-3.5 h-3.5" />
              </button>
            </div>
          </div>
        </div>

        <!-- Empty state -->
        <div v-if="toolkitStore.homeworkItems.length === 0 && !toolkitStore.upcomingSession">
          <ToolkitEmptyState
            :illustration="IlluTherapy"
            :message="$t('toolkit.emptyState.homework')"
          />
        </div>
      </div>
    </div>

    <!-- ═══════════════ TAB: GROUND ═══════════════ -->
    <div v-if="activeTab === 'ground'">
      <div class="mb-8">
        <h2 class="text-sm text-muted tracking-[0.2em] uppercase mb-4">
          {{ $t('toolkit.grounding.title') }}
        </h2>
        <div class="grid grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-3">
          <button
            v-for="tool in groundingTools"
            :key="tool.key"
            class="flex items-center gap-3 p-4 rounded-xl border border-default bg-elevated text-left hover:bg-muted hover:shadow-sm transition-all active:scale-[0.98]"
            @click="navigateTo(tool.path)"
          >
            <div class="w-11 h-11 rounded-xl bg-accented flex items-center justify-center shrink-0">
              <component :is="tool.icon" class="w-5 h-5 text-default" />
            </div>
            <div class="min-w-0">
              <p class="font-medium text-sm">{{ $t(tool.titleKey) }}</p>
              <p class="text-xs text-muted mt-0.5">{{ $t(tool.descriptionKey) }}</p>
            </div>
          </button>
        </div>
      </div>
    </div>
  </section>
</template>

<script lang="ts" setup>
import { Trash2, X, CalendarDays, ClipboardList, Stethoscope, MessageSquare } from "lucide-vue-next";
import IconBreathing from '~/components/Icons/IconBreathing.vue';
import IconFiveSenses from '~/components/Icons/IconFiveSenses.vue';
import IconBodyScan from '~/components/Icons/IconBodyScan.vue';
import IconAffirmations from '~/components/Icons/IconAffirmations.vue';
import IconQuickJournal from '~/components/Icons/IconQuickJournal.vue';
import IlluBrain from '~/components/Illustrations/IlluBrain.vue';
import IlluTherapy from '~/components/Illustrations/IlluTherapy.vue';
import { userJournalStore } from "~/stores/stores/user_journal";
import { useLearnedStore } from "~/stores/stores/user_learned";
import { useToolkitStore } from "~/stores/stores/therapy_toolkit_store";
import { JOURNEY_STEPS } from "~/types/therapy_toolkit";
import type { LocalTemplate } from "~/types/user_journal";

const { t } = useI18n();
const journalStore = userJournalStore();
const learnedStore = useLearnedStore();
const toolkitStore = useToolkitStore();

const journeySteps = JOURNEY_STEPS;

// ─── Tabs ────────────────────────────────────────────
const activeTab = ref('prepare');

const tabs = computed(() => [
  { label: t('toolkit.tabs.prepare'), value: 'prepare' },
  { label: t('toolkit.tabs.track'), value: 'track' },
  { label: t('toolkit.tabs.ground'), value: 'ground' },
]);

// ─── Session flow steps (for preview) ───────────────
const sessionFlowSteps = [
  { key: 'schedule', icon: CalendarDays, labelKey: 'toolkit.sessionFlow.step1' },
  { key: 'prepare', icon: ClipboardList, labelKey: 'toolkit.sessionFlow.step2' },
  { key: 'attend', icon: Stethoscope, labelKey: 'toolkit.sessionFlow.step3' },
  { key: 'reflect', icon: MessageSquare, labelKey: 'toolkit.sessionFlow.step4' },
];

// ─── Schedule session panel ──────────────────────────
const showSchedulePanel = ref(false);
const calendarDate = ref<any>(undefined);

const handleScheduleSession = async () => {
  if (!calendarDate.value) return;
  // UCalendar returns { year, month, day } object
  const d = calendarDate.value;
  const dateStr = `${d.year}-${String(d.month).padStart(2, '0')}-${String(d.day).padStart(2, '0')}`;
  await toolkitStore.createSession({
    session_date: dateStr,
    status: 'scheduled',
  });
  showSchedulePanel.value = false;
  calendarDate.value = undefined;
};

// ─── Session countdown ───────────────────────────────
const countdownText = computed(() => {
  if (!toolkitStore.upcomingSession?.session_date) return '';
  const sessionDate = new Date(toolkitStore.upcomingSession.session_date);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  sessionDate.setHours(0, 0, 0, 0);
  const diffDays = Math.round((sessionDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
  if (diffDays === 0) return t('toolkit.countdown.today');
  if (diffDays === 1) return t('toolkit.countdown.tomorrow');
  if (diffDays > 1) return t('toolkit.countdown.inDays', { count: diffDays });
  return '';
});

const countdownClass = computed(() => {
  if (!toolkitStore.upcomingSession?.session_date) return 'text-dimmed';
  const sessionDate = new Date(toolkitStore.upcomingSession.session_date);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  sessionDate.setHours(0, 0, 0, 0);
  const diffDays = Math.round((sessionDate.getTime() - today.getTime()) / (1000 * 60 * 60 * 24));
  if (diffDays === 0) return 'text-amber-400 font-medium';
  if (diffDays === 1) return 'text-amber-400';
  return 'text-dimmed';
});

// ─── Delete session ──────────────────────────────────
const confirmDeleteSession = async (id: string) => {
  if (confirm(t('toolkit.session.deleteConfirm'))) {
    await toolkitStore.deleteSession(id);
  }
};

// ─── Homework ────────────────────────────────────────
const newHomeworkText = ref('');
const showCompletedHomework = ref(false);

const pendingHomework = computed(() =>
  toolkitStore.homeworkItems.filter(h => !h.completed)
);

const completedHomework = computed(() =>
  toolkitStore.homeworkItems.filter(h => h.completed)
);

const completedHomeworkCount = computed(() => completedHomework.value.length);

const handleAddHomework = async () => {
  const text = newHomeworkText.value.trim();
  if (!text || !toolkitStore.upcomingSession) return;
  await toolkitStore.addHomework(toolkitStore.upcomingSession.id, text);
  newHomeworkText.value = '';
};

// ─── Load data on mount ──────────────────────────────
onMounted(async () => {
  await journalStore.getAllTemplates();
  await learnedStore.loadFromLocal();
  await toolkitStore.loadFromLocal();
});

// ─── Journey helpers ─────────────────────────────────
const getCollection = (collectionId: string): LocalTemplate | undefined => {
  return journalStore.templates.find(t => t.id === collectionId);
};

const getSlideGroupCount = (collectionId: string): number => {
  const collection = getCollection(collectionId);
  if (!collection) return 0;
  const groups = typeof collection.slide_groups === 'string'
    ? JSON.parse(collection.slide_groups)
    : collection.slide_groups;
  return groups?.length || 0;
};

const overallProgress = computed(() => {
  let totalCompleted = 0;
  let totalGroups = 0;
  for (const step of JOURNEY_STEPS) {
    totalCompleted += learnedStore.getCompletedCount(step.collectionId);
    totalGroups += getSlideGroupCount(step.collectionId);
  }
  return totalGroups > 0 ? Math.round((totalCompleted / totalGroups) * 100) : 0;
});

const hasJournals = computed(() => journalStore.journals.length > 0);

const navigateToCollection = (collectionId: string) => {
  navigateTo(`/toolkit/journey/${collectionId}`);
};

// ─── Date formatting ─────────────────────────────────
const { dateLocale } = useLocalizedDate();

const formatDate = (date?: string): string => {
  if (!date) return '';
  return new Date(date).toLocaleDateString(dateLocale.value, {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
};

// ─── Grounding tools ─────────────────────────────────
const groundingTools = [
  {
    key: 'breathing',
    titleKey: 'toolkit.grounding.breathing.title',
    descriptionKey: 'toolkit.grounding.breathing.description',
    icon: IconBreathing,
    path: '/toolkit/grounding/breathing',
  },
  {
    key: 'fiveSenses',
    titleKey: 'toolkit.grounding.fiveSenses.title',
    descriptionKey: 'toolkit.grounding.fiveSenses.description',
    icon: IconFiveSenses,
    path: '/toolkit/grounding/five-senses',
  },
  {
    key: 'bodyScan',
    titleKey: 'toolkit.grounding.bodyScan.title',
    descriptionKey: 'toolkit.grounding.bodyScan.description',
    icon: IconBodyScan,
    path: '/toolkit/grounding/body-scan',
  },
  {
    key: 'affirmations',
    titleKey: 'toolkit.grounding.affirmations.title',
    descriptionKey: 'toolkit.grounding.affirmations.description',
    icon: IconAffirmations,
    path: '/toolkit/grounding/affirmations',
  },
  {
    key: 'quickJournal',
    titleKey: 'toolkit.grounding.quickJournal.title',
    descriptionKey: 'toolkit.grounding.quickJournal.description',
    icon: IconQuickJournal,
    path: '/journaling',
  },
];
</script>

<style scoped>
.slide-down-enter-active,
.slide-down-leave-active {
  transition: all 0.25s ease;
  overflow: hidden;
}
.slide-down-enter-from,
.slide-down-leave-to {
  max-height: 0;
  opacity: 0;
}
.slide-down-enter-to,
.slide-down-leave-from {
  max-height: 400px;
  opacity: 1;
}
</style>
