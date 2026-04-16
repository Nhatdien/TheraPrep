<template>
  <section class="px-4 pb-24 pt-5 max-w-2xl mx-auto min-h-screen">
    <div
      class="w-full rounded-2xl border border-default/60 bg-default/70 backdrop-blur px-4 py-3 mb-5">
      <div class="flex items-start justify-between gap-3">
        <UButton variant="ghost" size="sm" @click="prevNode">
          <ChevronLeft class="w-4 h-4" />
        </UButton>
        <div class="text-center min-w-0">
          <p class="text-xs uppercase tracking-wide text-toned">
            {{ currentSlideMeta }}
          </p>
          <h1
            class="text-base sm:text-lg font-semibold text-highlighted truncate">
            {{ activeSlideGroup?.title || $t('slide.guidedFlow') }}
          </h1>
        </div>
        <UButton variant="ghost" size="sm" @click="closeSlideGroup">
          <X class="w-4 h-4" />
        </UButton>
      </div>
      <SegmentedProgress
        class="mt-3"
        :current="currentIndex + 1"
        :total="totalSlides" />
    </div>

    <UCarousel
      :watch-drag="true"
      ref="carousel"
      class="mt-2"
      v-slot="{ item }"
      :items="carouselItems"
      @select="(index: number) => (currentIndex = index)"
      :ui="{
        viewport: 'h-full',
        dot: 'w-6 h-1 rounded-full',
      }">
      <Transition name="guided-slide" mode="out-in">
        <div
          :key="currentIndex"
          class="h-[70vh] max-h-[760px] lg:h-[64vh] rounded-2xl border border-default/60 bg-default shadow-sm overflow-hidden flex flex-col">
          <!-- Per-slide illustration (shown when slide has illustration field) -->
          <div
            v-if="currentSlideIllustration"
            class="flex items-center justify-center bg-illus-dark shrink-0 h-36">
            <component :is="currentSlideIllustration" class="w-28 h-28" />
          </div>
          <!-- Slide content -->
          <div class="flex-1 overflow-y-auto p-5 sm:p-7">
            <component
              :is="renderSlide((item as any)?.content?.type)"
              :currentIndex
              :index="carouselItems.indexOf(item as any)"
              :content="(item as any)?.content"
              :slideGroupContext="activeSlideGroup"
              :collectionTitle="currentCollecton?.title"
              :initialContent="userJournalStore().currentWritingContent[(item as any)?.content?.question || (item as any)?.content?.question_content] || ''"></component>
          </div>
        </div>
      </Transition>
      <!-- <CommonMarkdownEditor v-model="item.currentNote"></CommonMarkdownEditor> -->
    </UCarousel>

    <!-- Button group, will include:
       - a button to make forward (user can still slide backward)
       - a button to edit text format
       - a button to open the chatbox with the chatbot to help with the journaling process -->
    <div class="w-full px-4 mt-2 hidden md:block">
      <div
        class="flex justify-between items-center rounded-2xl py-3">
        <UButton variant="ghost" :disabled="!canGoPrev" @click="prevNode"
          >{{ $t('common.back') }}</UButton
        >
        <UButton :variant="isLastSlide ? 'solid' : 'soft'" @click="nextNode">
          <span>{{ isLastSlide ? $t('slide.finish') : $t('slide.continue') }}</span>
          <ChevronRight class="ml-1 w-4 h-4" />
        </UButton>
      </div>
    </div>

    <button
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

const props = defineProps(["templateId"]);
const carousel = useTemplateRef("carousel");
const currentIndex = ref(0);

// Per-slide illustration — resolved from slide's `illustration` field (keyword string)
const currentSlideIllustration = computed(() => {
  const slide = carouselItems.value[currentIndex.value]?.content;
  if (!slide?.illustration) return null;
  return getIllustrationComponent(slide.illustration);
});

// Use the prop instead of route params
const {
  activeSlideGroup,
  saveJournal,
  closeSlideGroup,
  currentCollecton,
  markSlideGroupCompleted,
} = useSlideGroup({
  collectionId: props.templateId,
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
    };
  }) || [],
);

const totalSlides = computed(() => carouselItems.value.length || 1);
const currentSlideMeta = computed(
  () => t('slide.meta', { current: currentIndex.value + 1, total: totalSlides.value }),
);
const isLastSlide = computed(() => currentIndex.value >= totalSlides.value - 1);
const canGoPrev = computed(() => currentIndex.value > 0);

const nextNode = () => {
  if (!carousel.value?.emblaApi?.canScrollNext()) {
    // The journal will be created if the journal is not empty or
    // user have interact with the chatbot in that journal session
    if (
      !isEmptyJournal(userJournalStore().currentWritingContent as any) &&
      !userJournalStore().currentJournal
    ) {
      saveJournal(
        {
          content: generateJournalHtml(
            userJournalStore().currentWritingContent,
          ),
          mood_score: userJournalStore().currentMoodScore,
          mood_label: userJournalStore().currentMoodLabel,
          title: activeSlideGroup.value?.title || "",
        },
        (useRoute()?.params?.id || null) as string | null,
      );
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

.guided-slide-enter-active,
.guided-slide-leave-active {
  transition:
    opacity var(--motion-smooth) var(--motion-ease-standard),
    transform var(--motion-smooth) var(--motion-ease-standard);
}

.guided-slide-enter-from,
.guided-slide-leave-to {
  opacity: 0;
  transform: translateY(12px);
}
</style>
