<template>
  <section class="flex flex-col min-h-screen bg-background">
    <!-- Header: Back + Progress + Close -->
    <div class="px-4 pt-4 pb-2 max-w-2xl mx-auto w-full">
      <div class="flex items-center justify-between gap-3 mb-3">
        <UButton variant="ghost" size="sm" @click="prevNode">
          <ChevronLeft class="w-4 h-4" />
        </UButton>
        <div class="text-center min-w-0 flex-1">
          <p class="text-xs uppercase tracking-wide text-toned">
            {{ currentSlideMeta }}
          </p>
          <h1 class="text-sm font-semibold text-highlighted truncate">
            {{ activeSlideGroup?.title || $t('slide.guidedFlow') }}
          </h1>
        </div>
        <UButton variant="ghost" size="sm" @click="closeSlideGroup">
          <X class="w-4 h-4" />
        </UButton>
      </div>
      <SegmentedProgress
        :current="currentIndex + 1"
        :total="totalSlides" />
    </div>

    <!-- Slide Content (full-screen, no card) -->
    <UCarousel
      :watch-drag="true"
      ref="carousel"
      class="flex-1"
      v-slot="{ item }"
      :items="carouselItems"
      @select="(index: number) => (currentIndex = index)"
      :ui="{
        viewport: 'h-full',
        dot: 'w-6 h-1 rounded-full',
      }">
        <div
          :key="currentIndex"
          class="flex flex-col min-h-full">
          <!-- Per-slide illustration (shown when slide has illustration field) -->
          <div
            v-if="(item as any)?.illustration"
            class="flex items-center justify-center shrink-0 py-6">
            <component :is="(item as any)?.illustration" class="w-24 h-24" />
          </div>
          <!-- Slide content -->
          <div class="flex-1 overflow-y-auto px-5 pb-24">
            <component
              :is="renderSlide((item as any)?.content?.type)"
              :currentIndex
              :index="carouselItems.indexOf(item as any)"
              :content="(item as any)?.content"
              :slideGroupContext="activeSlideGroup"
              :collectionTitle="currentCollecton?.title"
              :onNext="nextNode"
              :initialContent="userJournalStore().currentWritingContent[(item as any)?.content?.question || (item as any)?.content?.question_content] || ''"></component>
          </div>
        </div>
    </UCarousel>


    <!-- Floating next button (only for non-journal slides on mobile) -->
    <button
      v-if="!isCurrentSlideJournal"
      type="button"
      class="floating-next-btn flex md:hidden"
      :aria-label="isLastSlide ? $t('slide.finish') : $t('slide.continue')"
      @click="nextNode">
      <ChevronRight class="w-5 h-5" />
    </button>
  </section>
</template>
<script lang="ts" setup>
import { ChevronRight, ChevronLeft, X } from "lucide-vue-next";
const { t } = useI18n();
import { getIllustrationComponent } from '~/components/Illustrations/index';
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
import SegmentedProgress from "~/components/Slide/SegmentedProgress.vue";

const props = defineProps(["templateId", "staticSlideGroup", "staticCollectionTitle"]);
const carousel = useTemplateRef("carousel");
const currentIndex = ref(0);

// Per-slide illustration — resolved from slide's `illustration` field (keyword string)
const resolveIllustration = (slide: any) => {
  if (!slide?.illustration) return null;
  return getIllustrationComponent(slide.illustration);
};

// Use the prop instead of route params
const {
  activeSlideGroup,
  saveJournal,
  closeSlideGroup,
  currentCollecton,
  markSlideGroupCompleted,
} = useSlideGroup({
  collectionId: props.templateId || undefined,
  staticSlideGroup: props.staticSlideGroup || undefined,
  staticCollectionTitle: props.staticCollectionTitle || undefined,
});

const componentMapping: any = {
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
};

const renderSlide = (type: string) => {
  return componentMapping[type] || componentMapping.journal_prompt;
};

const carouselItems = ref(
  // Support both 'slides' (new type) and 'content' (legacy/mock)
  (
    activeSlideGroup?.value?.slides ||
    (activeSlideGroup?.value as any)?.content ||
    []
  )?.map((slide: any) => {
    return {
      content: slide as any,
      currentNote: "",
      illustration: resolveIllustration(slide),
    };
  }) || [],
);

const totalSlides = computed(() => carouselItems.value.length || 1);
const currentSlideMeta = computed(
  () => t('slide.meta', { current: currentIndex.value + 1, total: totalSlides.value }),
);
const isLastSlide = computed(() => currentIndex.value >= totalSlides.value - 1);
const canGoPrev = computed(() => currentIndex.value > 0);

const isCurrentSlideJournal = computed(() => {
  const item = carouselItems.value[currentIndex.value];
  return item?.content?.type === 'journal_prompt';
});

const nextNode = async () => {
  if (!carousel.value?.emblaApi?.canScrollNext()) {
    // The journal will be created if the journal is not empty or
    // user have interact with the chatbot in that journal session
    if (
      !isEmptyJournal(userJournalStore().currentWritingContent as any) &&
      !userJournalStore().currentJournal
    ) {
      try {
        await saveJournal(
          {
            content: generateJournalHtml(
              userJournalStore().currentWritingContent,
            ),
            mood_score: userJournalStore().currentMoodScore,
            mood_label: userJournalStore().currentMoodLabel,
            title: activeSlideGroup.value?.title || "",
            sleep_score: userJournalStore().currentSleepScore,
          },
          (useRoute()?.params?.id || null) as string | null,
        );
      } catch (err) {
        console.error('[ModalContents] Journal save failed:', err);
        // TODO: show a user-facing error toast here
      }
    }

    // Mark slide group as completed for learn-type collections
    markSlideGroupCompleted();

    closeSlideGroup();
  } else {
    carousel.value?.emblaApi?.scrollNext();
  }

  //Reset the current journal
};

const prevNode = () => {
  if (!carousel.value?.emblaApi?.canScrollPrev()) {
    // The journal will be created if the journal is not empty or
    // user have interact with the chatbot in that journal session
    closeSlideGroup();
  } else {
    carousel.value?.emblaApi?.scrollPrev();
  }

  //Reset the current journal
};

onMounted(() => {
  // Init empty objects for editor store if needed (TipTap Store logic seems to require this)
  carouselItems.value.forEach((_item: unknown) => {
    // This usage of editors.push({}) seems to cause type errors,
    // suppressing for now if it works at runtime or use proper type
    // @ts-ignore
    useTiptapEditorStore().editors.push({});
  });
});
</script>

<style scoped>
.floating-next-btn {
  position: fixed;
  right: 1rem;
  bottom: calc(1rem + env(safe-area-inset-bottom));
  width: 3.5rem;
  height: 3.5rem;
  border-radius: 9999px;
  align-items: center;
  justify-content: center;
  background: rgb(var(--ui-primary));
  color: rgb(var(--ui-bg));
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.35);
  transition:
    transform var(--motion-fast) var(--motion-ease-standard),
    background-color var(--motion-standard) var(--motion-ease-standard);
}

.floating-next-btn:active {
  transform: scale(0.94);
}

</style>
