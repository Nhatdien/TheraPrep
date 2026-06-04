<template>
  <section class="p-4 max-w-lg mx-auto">
    <div class="flex justify-between w-full">
      <ChevronLeft @click="prevNode" />
      <div class="flex items-center gap-2">
        <span class="text-sm text-muted">{{ $t('journal.editing') }}</span>
        <X @click="closeWithoutSaving"/>
      </div>
    </div>
    <UCarousel
      :watch-drag="true"
      ref="carousel"
      class="mt-12"
      dots
      v-slot="{ item }"
      :items="(carouselItems as any[])"
      @select="(index: number) => (currentIndex = index)"
      :ui="{
        viewport: 'h-full',
        dot: 'w-6 h-1 rounded-none'
      }">
      <div class="min-h-[60vh] overflow-y-auto">
        <component
          :is="renderSlide((item as CarouselSlideItem)?.content?.type)"
          :currentIndex
          :index="carouselItems.indexOf(item as CarouselSlideItem)"
          :content="(item as CarouselSlideItem)?.content"
          :initialContent="(item as CarouselSlideItem)?.prefillContent"
          :slideGroupContext="activeSlideGroup"
          :collectionTitle="currentCollecton?.title"></component>
      </div>
    </UCarousel>
  </section>
</template>

<script lang="ts" setup>
import { ChevronRight, ChevronLeft, X, Check } from "lucide-vue-next";
import Document from "@/components/Slide/Document.vue";
import CTA from "@/components/Slide/CTA.vue";
import FurtherReading from "@/components/Slide/FutherReading.vue";
import JournalPrompt from "@/components/Slide/JournalPrompt.vue";
import SleepCheck from "~/components/Slide/SleepCheck.vue";
import MoodSlide from "~/components/Slide/MoodSlide.vue";
import DatePickerSlide from "~/components/Slide/DatePickerSlide.vue";
import StarRatingSlide from "~/components/Slide/StarRatingSlide.vue";
import ChecklistInputSlide from "~/components/Slide/ChecklistInputSlide.vue";
import Questionnaire from "~/components/Slide/Questionnaire.vue";
import CompletionSlide from "~/components/Slide/CompletionSlide.vue";
import { parseJournalHtml } from "~/utils/journal";
import type { LocalJournal } from "~/types/user_journal";

interface CarouselSlideItem {
  content: any;
  currentNote: string;
  prefillContent: string;
}

const props = defineProps<{
  journal: LocalJournal;
  templateId: string;
}>();

const emit = defineEmits(['saved', 'closed']);

const carousel = useTemplateRef("carousel");
const currentIndex = ref(0);
const isSaving = ref(false);

const store = userJournalStore();

// Get the slide group for this journal's collection
// Pass journalTitle to auto-detect slide group (morning vs evening) when not explicitly provided
const { activeSlideGroup, currentCollecton } = useSlideGroup({ 
  collectionId: props.templateId,
  journalTitle: props.journal.title
});

// Parse existing journal content to extract answers for each slide
const parseJournalContent = (contentHtml: string): Record<string, string> => {
  const parsed: Record<string, string> = {};
  
  if (!contentHtml) return parsed;
  
  // Use the parseJournalHtml utility to properly parse the HTML structure
  console.log(contentHtml);
  
  const parsed_from_util = parseJournalHtml(contentHtml);
  
  console.log('parsed', parsed_from_util);
  
  // Filter out metadata entries (those with keys that don't match any slide questions)
  const slides = activeSlideGroup.value?.slides || [];
  
  for (const [key, value] of Object.entries(parsed_from_util)) {
    // Skip metadata entries like "mood_score_10"
    if (key.includes('mood_score') || key.includes('_score')) {
      continue;
    }
    
    // Match the key to a slide question (case-insensitive)
    const matchedQuestion = slides.find((s: any) => {
      const slideQuestion = s.question || '';
      return slideQuestion.toLowerCase() === key.toLowerCase();
    });
    
    if (matchedQuestion && matchedQuestion.question) {
      parsed[matchedQuestion.question] = value;
    }
  }
  
  return parsed;
};

// Initialize store with journal data BEFORE component mounts (in setup)
// This ensures child components get the correct initial values
store.currentMoodScore = props.journal.mood_score ?? 5;
store.currentMoodLabel = props.journal.mood_label || "Okay";
store.currentSleepScore = props.journal.sleep_score ?? null;
store.currentJournal = props.journal;

// Don't call parseJournalContent here - it depends on activeSlideGroup which may not be loaded yet
// Instead, we'll update store.currentWritingContent after templates are loaded in onMounted
const journalContent = ref(props.journal.content_html || props.journal.content);

const componentMapping: Record<string, any> = {
  doc: Document,
  journal_prompt: JournalPrompt,
  further_reading: FurtherReading,
  cta: CTA,
  sleep_check: SleepCheck,
  mood_check: MoodSlide,
  emotion_log: MoodSlide,
  date_picker: DatePickerSlide,
  star_rating: StarRatingSlide,
  checklist_input: ChecklistInputSlide,
  questionnaire: Questionnaire,
  completion: CompletionSlide,
}

const renderSlide = (type: string) => {
  return componentMapping[type] || componentMapping.journal_prompt;
}

// Build carousel items with prefilled content
// Include templatesLoaded to ensure reactivity updates when templates are loaded
const carouselItems = computed((): CarouselSlideItem[] => {
  // Access templatesLoaded to create dependency
  void templatesLoaded.value;
  
  const slides = activeSlideGroup.value?.slides || (activeSlideGroup.value as any)?.content || [];
  const prefillData = parseJournalContent(props.journal.content_html || props.journal.content);
  
  return slides.map((slide: any) => {
    const question = slide.question || slide.question_content;
    return {
      content: slide,
      currentNote: "",
      prefillContent: prefillData[question] || "",
    };
  });
});

// Reactive trigger to force carousel items to update when templates load
const templatesLoaded = ref(false);

const initTemplates = async () => {
  // Ensure database and templates are initialized before rendering slides
  // This is needed because EditModalContents can be opened directly from journal list
  // without going through the template selection flow
  if (!store.isInitialized) {
    console.log("[EditModalContents] Initializing database and loading templates...");
    await store.initializeDatabase();
  }
  // Force reactivity update after templates are loaded
  templatesLoaded.value = true;
};

// Initialize editor store slots
onMounted(async () => {
  // Wait for templates to be loaded before rendering carousel items
  await initTemplates();
  
  // Init editor store
  carouselItems.value.forEach(() => {
    // @ts-ignore
    useTiptapEditorStore().editors.push({});
  });
});

const nextNode = () => {
  if (!carousel.value?.emblaApi?.canScrollNext()) {
    // At the end, save and close
    saveJournalChanges();
  } else {
    carousel.value?.emblaApi?.scrollNext();
  }
};

const prevNode = () => {
  if (!carousel.value?.emblaApi?.canScrollPrev()) {
    closeWithoutSaving();
  } else {
    carousel.value?.emblaApi?.scrollPrev();
  }
};

const saveJournalChanges = async () => {
  try {
    isSaving.value = true;
    
    const newContent = generateJournalHtml(store.currentWritingContent);
    
    await store.updateJournal({
      id: props.journal.id,
      title: props.journal.title,
      content: newContent,
      content_html: newContent,
      mood_score: store.currentMoodScore,
      mood_label: store.currentMoodLabel,
      sleep_score: store.currentSleepScore,
    });
    
    // Clear session
    clearSession();
    
    emit('saved');
  } catch (error) {
    console.error("[EditModal] Error saving:", error);
  } finally {
    isSaving.value = false;
  }
};

const closeWithoutSaving = () => {
  clearSession();
  emit('closed');
};

const clearSession = () => {
  store.currentWritingContent = {};
  store.currentJournal = null;
  useTiptapEditorStore().editors = [];
};
</script>
