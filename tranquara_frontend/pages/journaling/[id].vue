<template>
  <div class="h-full">
    <!-- Loading State -->
    <div v-if="isLoading" class="flex items-center justify-center h-full">
      <Icon name="i-lucide-loader-2" class="w-8 h-8 animate-spin text-primary" />
    </div>

    <!-- ============ EDIT MODE ============ -->

    <!-- Slide Edit Mode (for template journals with collection_id) -->
    <div v-else-if="isEditing && journal && journal.collection_id" class="h-full">
      <JournalEditModalContents
        :journal="journal"
        :templateId="journal.collection_id"
        @saved="onSaved"
        @closed="onEditClosed"
      />
    </div>

    <!-- Free-form Edit Mode (for journals without collection_id) -->
    <div v-else-if="isEditing && journal" class="flex flex-col min-h-screen bg-background">
      <!-- Header -->
      <header class="flex items-center justify-between p-4 border-b border-default md:px-6 xl:px-8">
        <UButton variant="ghost" icon="i-lucide-arrow-left" @click="onEditClosed" />
        <h1 class="text-lg font-semibold md:text-xl">{{ $t('journal.editJournal') }}</h1>
        <UButton variant="ghost" icon="i-lucide-check" @click="saveAndClose" :disabled="!hasContent" />
      </header>

      <!-- Title Input -->
      <div class="px-6 pt-4 max-w-prose mx-auto w-full md:pt-6">
        <input
          v-model="title"
          type="text"
          :placeholder="$t('journal.titlePlaceholder')"
          class="w-full text-2xl font-semibold bg-transparent border-none outline-none placeholder-muted"
        />
      </div>

      <!-- Date + Auto-save Status -->
      <div class="px-6 py-2 max-w-prose mx-auto w-full flex items-center justify-between">
        <span class="text-sm text-muted">{{ formattedDate }}</span>
        <span class="text-xs text-muted">{{ autoSaveStatusText }}</span>
      </div>

      <!-- TipTap Editor -->
      <div class="flex-1 px-6 pb-28 max-w-prose mx-auto w-full journal-content">
        <CommonMarkdownEditor
          ref="editorRef"
          v-model="content"
          @on-update="onContentUpdate"
        />
      </div>

      <!-- Floating Toolbar -->
      <JournalFloatingToolbar
        :mood-score="moodScore"
        :loading="isGeneratingQuestion"
        :disabled="!hasContent || isGeneratingQuestion"
        @ai-click="handleGoDeeper()"
        @direction-click="showDirectionPicker = true"
        @format-click="isFormatDrawerOpen = true"
        @mood-click="showMoodPicker = true"
      />

      <!-- Direction Picker -->
      <JournalGoDeepDirections
        v-model="showDirectionPicker"
        headless
        :loading="isGeneratingQuestion"
        :disabled="!hasContent || isGeneratingQuestion"
        @select="handleGoDeeper"
      />

      <!-- Format Drawer -->
      <JournalFormatDrawer v-model="isFormatDrawerOpen" :editor="editorRef?.editor" />

      <!-- Mood Picker Modal -->
      <UModal v-model:open="showMoodPicker">
        <template #content>
          <div class="p-6 w-full max-w-md mx-auto">
            <h3 class="text-lg font-semibold mb-4 text-center">{{ $t('journal.howFeeling') }}</h3>
            <EmotionSliderV2 v-model="moodScore" />
            <UButton block class="mt-4" @click="confirmMood">{{ $t('common.confirm') }}</UButton>
          </div>
        </template>
      </UModal>
    </div>

    <!-- ============ VIEW MODE (default) ============ -->
    <JournalDetailView
      v-else-if="journal"
      :journal="journal"
      :is-syncing="journalStore.isSyncing"
      :is-deleting="isDeleting"
      @back="router.back()"
      @edit="enterEdit"
      @delete="deleteJournal"
    />

    <!-- Not Found -->
    <div v-else class="flex items-center justify-center h-full">
      <p class="text-muted">{{ $t('journal.notFound') }}</p>
    </div>

    <!-- Crisis Detection Modal -->
    <CrisisModal v-model="isCrisisModalOpen" />
  </div>
</template>

<script setup lang="ts">
import { userJournalStore } from "~/stores/stores/user_journal";
import { useAuthStore } from "~/stores/stores/auth_store";
import EmotionSliderV2 from "~/components/Common/EmotionSliderV2.vue";
import TranquaraSDK from "~/stores/tranquara_sdk";
import type { LocalJournal } from "~/types/user_journal";
import { useAIGuard } from "~/composables/useAIGuard";
import { useCrisisDetection } from "~/composables/useCrisisDetection";
import { useFallbackQuestions } from "~/composables/useFallbackQuestions";

definePageMeta({ layout: "detail" });

const route = useRoute();
const router = useRouter();
const journalStore = userJournalStore();
const { canUseAI, yourStory } = useAIGuard();
const { t, locale } = useI18n();
const { formatDate: formatLocalDate } = useLocalizedDate();
const { isCrisisModalOpen, detectCrisis, showCrisisModal } = useCrisisDetection();
const { getFallbackQuestion } = useFallbackQuestions();

// State
const isLoading = ref(true);
const journal = ref<LocalJournal | null>(null);
const isEditing = ref(false);
const isDeleting = ref(false);

// Free-form editor state
const title = ref("");
const content = ref("");
const moodScore = ref(5);
const moodLabel = ref(t('journal.moodLabels.5'));
const showMoodPicker = ref(false);
const editorRef = ref<any>(null);
const autoSaveStatus = ref("ready");
const isGeneratingQuestion = ref(false);
const isFormatDrawerOpen = ref(false);
const showDirectionPicker = ref(false);

// Map autoSaveStatus keys to i18n
const autoSaveStatusText = computed(() => {
  return t(`journal.autoSave.${autoSaveStatus.value}`);
});

let autoSaveTimeout: ReturnType<typeof setTimeout> | null = null;

// Load journal on mount
onMounted(async () => {
  const journalId = route.params.id as string;
  
  try {
    if (!journalStore.isInitialized) {
      await journalStore.initializeDatabase();
    }
    
    const loadedJournal = await journalStore.getJournalById(journalId);
    if (loadedJournal) {
      journal.value = loadedJournal;
      // Auto-enter edit mode when navigated from learn_and_prepare journal view
      if (route.query.mode === 'edit') {
        enterEdit();
      }
    } else {
      router.push("/history");
    }
  } catch (error) {
    console.error("Error loading journal:", error);
    router.push("/history");
  } finally {
    isLoading.value = false;
  }
});

const formattedDate = computed(() => {
  if (journal.value?.created_at) {
    return formatLocalDate(journal.value.created_at, {
      weekday: "long",
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  }
  return "";
});

const hasContent = computed(() => {
  const stripped = content.value.replace(/<[^>]*>/g, "").trim();
  return stripped.length > 0;
});

const selectedMoodIcon = computed(() => {
  const v = moodScore.value;
  if (v <= 4) return 'i-lucide-frown';
  if (v <= 6) return 'i-lucide-meh';
  return 'i-lucide-smile';
});

const computedMoodLabel = computed(() => t(`journal.moodLabels.${moodScore.value}`) || t('journal.moodLabels.5'));

watch(moodScore, () => {
  moodLabel.value = computedMoodLabel.value;
}, { immediate: true });

const onSaved = async () => {
  // Reload journal data and return to view mode
  const journalId = route.params.id as string;
  const updated = await journalStore.getJournalById(journalId);
  if (updated) journal.value = updated;
  isEditing.value = false;
};

const onEditClosed = () => {
  isEditing.value = false;
};

// --- View mode helpers ---

const enterEdit = () => {
  if (journal.value && !journal.value.collection_id) {
    // Prefill free-form editor state from journal
    title.value = journal.value.title || "";
    content.value = journal.value.content_html || journal.value.content || "";
    moodScore.value = journal.value.mood_score ?? 5;
    moodLabel.value = journal.value.mood_label || t('journal.moodLabels.5');
  }
  isEditing.value = true;
};

const deleteJournal = async () => {
  if (!journal.value) return;
  try {
    isDeleting.value = true;
    await journalStore.deleteJournal(journal.value.id);
    router.push('/history');
  } catch (error) {
    console.error('Error deleting journal:', error);
    isDeleting.value = false;
  }
};

const onContentUpdate = () => {
  autoSaveStatus.value = "typing";
  if (autoSaveTimeout) clearTimeout(autoSaveTimeout);
  autoSaveTimeout = setTimeout(() => {
    autoSaveStatus.value = "unsavedChanges";
  }, 1000);
};

const confirmMood = () => {
  moodLabel.value = computedMoodLabel.value;
  showMoodPicker.value = false;
};

const insertQuestionToEditor = (question: string) => {
  if (editorRef.value?.editor) {
    editorRef.value.editor
      .chain()
      .focus('end')
      .insertContent('<p></p>')
      .insertContent('<p class="ai-suggestion" style="color: #888; font-style: italic;">' + question + '</p>')
      .insertContent('<p></p>')
      .run();
  }
};

const handleGoDeeper = async (direction?: string) => {
  if (!hasContent.value || isGeneratingQuestion.value) return;
  if (!canUseAI()) return;
  
  // Layer 1: Client-side keyword crisis detection (instant, 0 latency)
  const plainText = content.value.replace(/<[^>]*>/g, '').trim();
  const clientCrisisDetected = detectCrisis(plainText);
  if (clientCrisisDetected) {
    showCrisisModal();
  }
  
  try {
    isGeneratingQuestion.value = true;
    autoSaveStatus.value = "thinking";
    
    const sdk = TranquaraSDK.getInstance();
    const userId = useAuthStore().getUserUUID;
    
    const response = await sdk.analyzeJournal({
      user_id: userId || '',
      content: plainText,
      mood_score: moodScore.value,
      slide_prompt: undefined,
      direction: direction as 'why' | 'emotions' | 'patterns' | 'challenge' | 'growth',
      your_story: yourStory.value || undefined,
      app_language: locale.value,
    });
    
    // Layer 2: AI-based crisis detection — backend returns structured response
    if (response.crisis_detected) {
      // AI detected crisis — show modal (if not already shown by Layer 1)
      if (!clientCrisisDetected) {
        showCrisisModal();
      }
      autoSaveStatus.value = "unsavedChanges";
    } else if (response.question) {
      // Safe — insert the follow-up question
      insertQuestionToEditor(response.question);
      autoSaveStatus.value = "questionAdded";
      setTimeout(() => { autoSaveStatus.value = "unsavedChanges"; }, 2000);
    }
  } catch (error) {
    // Fallback question when AI fails
    console.error("[GoDeeper] Error:", error);
    const fallbackQ = getFallbackQuestion(direction);
    const prefix = t('goDeeper.fallbackMessage');
    insertQuestionToEditor(prefix + ' ' + fallbackQ);
    autoSaveStatus.value = "questionAdded";
    setTimeout(() => { autoSaveStatus.value = "unsavedChanges"; }, 2000);
  } finally {
    isGeneratingQuestion.value = false;
  }
};

const saveAndClose = async () => {
  if (!hasContent.value || !journal.value) return;

  try {
    autoSaveStatus.value = "saving";
    
    await journalStore.updateJournal({
      id: journal.value.id,
      title: title.value || t('journal.untitledJournal'),
      content: content.value,
      content_html: content.value,
      mood_score: moodScore.value,
      mood_label: moodLabel.value,
    });

    // Reload journal and return to view mode
    const updated = await journalStore.getJournalById(journal.value.id);
    if (updated) journal.value = updated;
    isEditing.value = false;
    autoSaveStatus.value = "saved";
  } catch (error) {
    console.error("[EditJournal] Error saving:", error);
    autoSaveStatus.value = "errorSaving";
  }
};

onUnmounted(() => {
  if (autoSaveTimeout) clearTimeout(autoSaveTimeout);
});
</script>

<style scoped>
.journal-content :deep(.tiptap) {
  font-size: 1.125rem;
  line-height: 1.75;
}
</style>