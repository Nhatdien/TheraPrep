<template>
  <div class="flex flex-col min-h-screen bg-background">
    <!-- Header -->
    <header
      class="flex items-center justify-between p-4 border-b border-default">
      <UButton
        variant="ghost"
        icon="i-lucide-arrow-left"
        @click="router.back()" />
      <h1 class="text-lg font-semibold">{{ $t("journal.newJournal") }}</h1>
      <UButton
        variant="ghost"
        icon="i-lucide-check"
        @click="saveAndClose"
        :disabled="!hasContent" />
    </header>

    <!-- Title Input -->
    <div class="px-6 pt-4 max-w-prose mx-auto w-full">
      <input
        v-model="title"
        type="text"
        :placeholder="$t('journal.titlePlaceholder')"
        class="w-full text-2xl font-semibold bg-transparent border-none outline-none placeholder-muted" />
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
        @on-update="onContentUpdate" />
    </div>

    <!-- Floating Toolbar FABs -->
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
      @select="handleGoDeeperWithDirection"
    />

    <!-- Format Drawer -->
    <JournalFormatDrawer v-model="isFormatDrawerOpen" :editor="editorRef?.editor" />

    <!-- Mood Picker Modal -->
    <UModal v-model:open="showMoodPicker">
      <template #content>
        <div class="p-6 w-full max-w-md mx-auto">
          <h3 class="text-lg font-semibold mb-4 text-center">
            {{ $t("journal.howFeeling") }}
          </h3>
          <EmotionSliderV2 v-model="moodScore" />
          <UButton block class="mt-4" @click="confirmMood">{{
            $t("common.confirm")
          }}</UButton>
        </div>
      </template>
    </UModal>

    <!-- Crisis Detection Modal -->
    <CrisisModal v-model="isCrisisModalOpen" />
  </div>
</template>

<style scoped>
.journal-content :deep(.tiptap) {
  font-size: 1.125rem;
  line-height: 1.75;
}
</style>

<script setup lang="ts">
import { userJournalStore } from "~/stores/stores/user_journal";
import { useAuthStore } from "~/stores/stores/auth_store";
import EmotionSliderV2 from "~/components/Common/EmotionSliderV2.vue";
import TranquaraSDK from "~/stores/tranquara_sdk";
import { useAIGuard } from "~/composables/useAIGuard";
import { useCrisisDetection } from "~/composables/useCrisisDetection";
import { streamToEditor } from "~/utils/journal";

definePageMeta({
  layout: "detail",
});

const router = useRouter();
const journalStore = userJournalStore();
const authStore = useAuthStore();
const { canUseAI, yourStory } = useAIGuard();
const { t, locale } = useI18n();
const { formatDate: formatLocalDate } = useLocalizedDate();
const { detectCrisis, showCrisisModal, isCrisisModalOpen } = useCrisisDetection();

// Form state
const title = ref("");
const content = ref("");
const moodScore = ref(5); // 1-10 scale (new EmotionSliderV2)
const moodLabel = ref(t('journal.moodLabels.5'));
const showMoodPicker = ref(false);
const editorRef = ref<any>(null);
const autoSaveStatus = ref("ready");
const lastSavedAt = ref<Date | null>(null);
const isGeneratingQuestion = ref(false);
const isFormatDrawerOpen = ref(false);
const showDirectionPicker = ref(false);
const streamAbortController = ref<AbortController | null>(null);

// Map autoSaveStatus keys to i18n
const autoSaveStatusText = computed(() => {
  return t(`journal.autoSave.${autoSaveStatus.value}`);
});

// Debounce for auto-save
let autoSaveTimeout: ReturnType<typeof setTimeout> | null = null;

// Computed
const formattedDate = computed(() => {
  return formatLocalDate(new Date(), {
    weekday: "long",
    year: "numeric",
    month: "long",
    day: "numeric",
  });
});

const hasContent = computed(() => {
  // Strip HTML tags and check if there's actual text
  const stripped = content.value.replace(/<[^>]*>/g, "").trim();
  return stripped.length > 0;
});

const selectedMoodIcon = computed(() => {
  const v = moodScore.value;
  if (v <= 4) return 'i-lucide-frown';
  if (v <= 6) return 'i-lucide-meh';
  return 'i-lucide-smile';
});

// Mood labels for 1-10 scale (use i18n)
const computedMoodLabel = computed(() => {
  return (
    t(`journal.moodLabels.${moodScore.value}`) || t("journal.moodLabels.5")
  );
});

// Methods
const onContentUpdate = () => {
  // Debounced auto-save indicator
  autoSaveStatus.value = "typing";

  if (autoSaveTimeout) {
    clearTimeout(autoSaveTimeout);
  }

  autoSaveTimeout = setTimeout(() => {
    autoSaveStatus.value = "autoSaved";
    lastSavedAt.value = new Date();
  }, 1000);
};

const confirmMood = () => {
  moodLabel.value = computedMoodLabel.value;
  showMoodPicker.value = false;
};

const handleGoDeeperWithDirection = (direction: string) => {
  handleGoDeeper(direction);
};

const handleGoDeeper = async (direction?: string) => {
  if (!hasContent.value || isGeneratingQuestion.value) return;
  if (!canUseAI()) return;

  // Cancel any previous stream
  if (streamAbortController.value) {
    streamAbortController.value.abort();
  }
  streamAbortController.value = new AbortController();

  // Layer 1: Client-side keyword crisis detection (instant, 0 latency)
  const plainText = content.value.replace(/<[^>]*>/g, "").trim();
  const clientCrisisDetected = detectCrisis(plainText);
  if (clientCrisisDetected) {
    showCrisisModal();
  }

  try {
    isGeneratingQuestion.value = true;
    autoSaveStatus.value = "thinking";

    const sdk = TranquaraSDK.getInstance();
    const userId = useAuthStore().getUserUUID;

    const stream = sdk.analyzeJournalStream({
      user_id: userId || "",
      content: plainText,
      mood_score: moodScore.value,
      slide_prompt: undefined,
      direction: direction as any,
      your_story: yourStory.value || undefined,
      app_language: locale.value,
    }, streamAbortController.value.signal);

    await streamToEditor(editorRef.value?.editor, stream, {
      onCrisis: () => {
        if (!clientCrisisDetected) showCrisisModal();
        autoSaveStatus.value = "ready";
      },
      onError: (err) => {
        console.error("[GoDeeper] Stream error:", err);
        autoSaveStatus.value = "errorGenerating";
        setTimeout(() => { autoSaveStatus.value = "ready"; }, 2000);
      },
      onDone: () => {
        autoSaveStatus.value = "questionAdded";
        setTimeout(() => { autoSaveStatus.value = "ready"; }, 2000);
      },
    });
  } catch (error) {
    console.error("[GoDeeper] Error:", error);
    autoSaveStatus.value = "errorGenerating";
    setTimeout(() => {
      autoSaveStatus.value = "ready";
    }, 2000);
  } finally {
    isGeneratingQuestion.value = false;
    streamAbortController.value = null;
  }
};

const saveAndClose = async () => {
  if (!hasContent.value) return;

  try {
    autoSaveStatus.value = "saving";

    // Ensure database is initialized
    if (!journalStore.isInitialized) {
      await journalStore.initializeDatabase();
    }

    await journalStore.createJournal({
      collection_id: null, // Free-form journal has no collection
      title: title.value || t("journal.untitledJournal"),
      content: content.value,
      content_html: content.value, // For free-form, content IS html
      mood_score: moodScore.value,
      mood_label: moodLabel.value,
    });

    autoSaveStatus.value = "saved";

    // Navigate back after short delay to show "Saved!" status
    setTimeout(() => {
      router.push("/history");
    }, 300);
  } catch (error) {
    console.error("[FreeformJournal] Error saving:", error);
    autoSaveStatus.value = "errorSaving";
  }
};

// Cleanup
onUnmounted(() => {
  if (autoSaveTimeout) {
    clearTimeout(autoSaveTimeout);
  }
  if (streamAbortController.value) {
    streamAbortController.value.abort();
    streamAbortController.value = null;
  }
});
</script>
