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

    <!-- Media attachments -->
    <MediaUploader
      :max-images="5"
      :current-count="attachedMedia.length"
      :initial-media="initialMedia"
      class="mt-3"
      @uploaded="onMediaUploaded"
      @removed="onMediaRemoved"
      @error="(msg: string) => console.warn('Media:', msg)"
    />

    <!-- Go Deeper with Direction Selection -->
    <div class="mt-5 flex justify-end" v-if="hasContent && !isGeneratingQuestion">
      <JournalGoDeepDirections
        :loading="isGeneratingQuestion"
        :disabled="!hasContent || isGeneratingQuestion"
        @select="handleGoDeeper"
      />
    </div>

    <!-- Persistent AI loading indicator (visible outside slideover) -->
    <div v-if="isGeneratingQuestion" class="mt-4 flex items-center justify-center gap-2 text-sm text-muted">
      <span class="inline-block w-4 h-4 border-2 border-primary border-t-transparent rounded-full animate-spin" />
      <span>{{ $t('goDeeper.thinking') }}</span>
    </div>
  </div>
</template>

<script lang="ts" setup>
import TranquaraSDK from "~/stores/tranquara_sdk";
import { useAuthStore } from "~/stores/stores/auth_store";
import { useAIGuard } from "~/composables/useAIGuard";

const currentNote = ref("");
const isGeneratingQuestion = ref(false);
const { canUseAI, yourStory } = useAIGuard();
const { locale } = useI18n();
const store = userJournalStore();

const attachedMedia = ref<Array<{ id: string; url: string; alt?: string }>>([]);

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
  initialMedia: {
    type: Array as PropType<Array<{ id: string; url: string; alt?: string }>>,
    default: () => [],
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

const onMediaUploaded = (mediaId: string, url: string) => {
  attachedMedia.value.push({ id: mediaId, url });
  store.updateSlideMedia(props.index, [...attachedMedia.value]);
};

const onMediaRemoved = (mediaId: string) => {
  attachedMedia.value = attachedMedia.value.filter((m) => m.id !== mediaId);
  store.updateSlideMedia(props.index, [...attachedMedia.value]);
};

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
  
  try {
    isGeneratingQuestion.value = true;
    
    const sdk = TranquaraSDK.getInstance();
    
    // Get plain text content from editor
    const plainText = currentNote.value.replace(/<[^>]*>/g, '').trim();
    const slidePrompt = props.content?.question || props.content?.question_content;
    const userId = useAuthStore().getUserUUID;
    
    const response = await sdk.analyzeJournal({
      user_id: userId || '',
      content: plainText,
      mood_score: userJournalStore().currentMoodScore,
      slide_prompt: slidePrompt,
      slide_group_context: props.slideGroupContext,  // Pass full slide group context
      current_slide_id: props.content?.id,            // Pass current slide ID
      collection_title: props.collectionTitle,         // Pass collection title
      direction: direction as 'why' | 'emotions' | 'patterns' | 'challenge' | 'growth',  // Pass selected direction
      your_story: yourStory.value || undefined,
      app_language: locale.value,
    });
    
    // Insert AI question into editor with muted styling
    if (editor.value?.editor) {
      const editorInstance = editor.value.editor;
      
      editorInstance
        .chain()
        .focus('end')
        .insertContent('<p></p>', {
          contentType: 'html',
        })
        .insertContent(`<p class="ai-suggestion text-muted italic">${response.question}</p>`, {
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

  // Pre-fill media if provided (for edit mode)
  if (props.initialMedia?.length) {
    attachedMedia.value = [...props.initialMedia];
    store.updateSlideMedia(props.index, [...attachedMedia.value]);
  }
  
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
