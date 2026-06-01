<template>
  <div>
    <div class="mb-5">
      <h2 class="text-2xl sm:text-3xl font-semibold leading-tight text-highlighted text-center">{{ content?.question || content?.question_content || $t('slide.journalDefaultQuestion') }}</h2>
      <p v-if="content?.content || content?.question_description" class="text-muted text-sm sm:text-base leading-7 mt-3 text-center">
        {{ content?.content || content?.question_description }}
      </p>
    </div>
    <CommonMarkdownEditor
      ref="editor"
      @on-update="onEditorUpdate"
      v-model="currentNote" />
    
    <!-- Go Deeper with Direction Selection -->
    <div class="mt-5 flex justify-end" v-if="hasContent">
      <JournalGoDeepDirections
        :loading="isGeneratingQuestion"
        :disabled="!hasContent || isGeneratingQuestion"
        @select="handleGoDeeper"
      />
    </div>

    <!-- Crisis Detection Modal -->
    <CrisisModal v-model="isCrisisModalOpen" />
  </div>
</template>

<script lang="ts" setup>
import TranquaraSDK from "~/stores/tranquara_sdk";
import { useAuthStore } from "~/stores/stores/auth_store";
import { useAIGuard } from "~/composables/useAIGuard";
import { useCrisisDetection } from "~/composables/useCrisisDetection";

const currentNote = ref("");
const isGeneratingQuestion = ref(false);
const { canUseAI, yourStory } = useAIGuard();
const { locale } = useI18n();
const { isCrisisModalOpen, detectCrisis, showCrisisModal } = useCrisisDetection();

const editor = ref()
const props = defineProps({
  content: {
    type: Object,
    required: true,
  },
  currentIndex: {
    type: Number,
    required: true
  },
  index: {
    type: Number,
    required: true,
  },
  initialContent: {
    type: String,
    default: "",
  },
  slideGroupContext: {
    type: Object,
    default: null,
  },
  collectionTitle: {
    type: String,
    default: null,
  },
});

// Computed to check if there's content
const hasContent = computed(() => {
  const stripped = currentNote.value.replace(/<[^>]*>/g, "").trim();
  return stripped.length > 0;
});

const onEditorUpdate = () => {
  // Use question text, falling back to content id to avoid 'undefined' as key
  const key = props.content?.question || props.content?.question_content || props.content?.id || 'journal_entry';
  userJournalStore().updateCurrentWritingContent(
    key,
    currentNote.value
  );
};

const handleGoDeeper = async (direction: string) => {
  if (!hasContent.value || isGeneratingQuestion.value) return;
  if (!canUseAI()) return;
  
  // Layer 1: Client-side keyword crisis detection (instant, 0 latency)
  const plainText = currentNote.value.replace(/<[^>]*>/g, '').trim();
  const clientCrisisDetected = detectCrisis(plainText);
  if (clientCrisisDetected) {
    showCrisisModal();
  }
  
  try {
    isGeneratingQuestion.value = true;
    
    const sdk = TranquaraSDK.getInstance();
    
    const slidePrompt = props.content?.question || props.content?.question_content;
    const userId = useAuthStore().getUserUUID;
    
    const response = await sdk.analyzeJournal({
      user_id: userId || '',
      content: plainText,
      mood_score: userJournalStore().currentMoodScore,
      slide_prompt: slidePrompt,
      slide_group_context: props.slideGroupContext,
      current_slide_id: props.content?.id,
      collection_title: props.collectionTitle,
      direction: direction as 'why' | 'emotions' | 'patterns' | 'challenge' | 'growth',
      your_story: yourStory.value || undefined,
      app_language: locale.value,
    });
    
    // Layer 2: AI-based crisis detection
    if (response.crisis_detected) {
      if (!clientCrisisDetected) {
        showCrisisModal();
      }
      return; // Don't insert question
    }
    
    // Safe — insert AI question into editor
    if (response.question && editor.value?.editor) {
      const editorInstance = editor.value.editor;
      
      editorInstance
        .chain()
        .focus('end')
        .insertContent('<p></p>', {
          contentType: 'html',
        })
        .insertContent(`<p class="ai-suggestion" style="color: #888; font-style: italic;">${response.question}</p>`, {
          contentType: 'html',
        })
        .insertContent('<p></p>', {
          contentType: 'html',
        })
        .run();
    }
  } catch (error) {
    console.error("[GoDeeper] Error:", error);
  } finally {
    isGeneratingQuestion.value = false;
  }
};

onMounted(() => {
  useTiptapEditorStore().editors[props.index] = editor.value?.editor;
  
  // Pre-fill content if provided (for edit mode)
  if (props.initialContent) {
    currentNote.value = props.initialContent;
    // Update editor content
    if (editor.value?.editor) {
      editor.value.editor.commands.setContent(props.initialContent);
    }
    // Also update the store
    const key = props.content?.question || props.content?.question_content || props.content?.id || 'journal_entry';
    userJournalStore().updateCurrentWritingContent(
      key,
      props.initialContent
    );
  }
});

// Watch for initialContent changes (in case it's provided after mount)
watch(() => props.initialContent, (newContent) => {
  if (!newContent || !editor.value?.editor) return;
  // Skip if this update was triggered by our own typing (prevents feedback loop
  // where onEditorUpdate → store → initialContent prop → setContent → space lost)
  if (newContent === currentNote.value) return;
  currentNote.value = newContent;
  editor.value.editor.commands.setContent(newContent);
  const key = props.content?.question || props.content?.question_content || props.content?.id || 'journal_entry';
  userJournalStore().updateCurrentWritingContent(
    key,
    newContent
  );
}, { immediate: true });

watch(() => [props.currentIndex, props.index], () => {
  if(props.currentIndex === props.index) {
    useTiptapEditorStore().editors[props.currentIndex]?.commands?.focus()
  }
}, {deep: true, immediate: true})

watch(
  () => userJournalStore().currentWritingContent,
  () => {
    const htmlString = generateJournalHtml(
      userJournalStore().currentWritingContent
    );
  },
  { deep: true }
);
</script>
