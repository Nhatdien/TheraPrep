<template>
  <div class="flex flex-col min-h-screen">
    <!-- Header -->
    <div class="flex items-center justify-between px-4 py-4 border-b border-default">
      <button class="p-2 rounded-full hover:bg-muted" @click="$router.back()">
        <ChevronLeft class="w-5 h-5" />
      </button>
      <h1 class="text-lg font-semibold">{{ $t('myTemplate.pageTitle') }}</h1>
      <UButton
        size="sm"
        :loading="saving"
        :disabled="saving"
        @click="handleSave"
      >
        {{ saving ? $t('myTemplate.saving') : $t('myTemplate.save') }}
      </UButton>
    </div>

    <!-- Body -->
    <div class="flex-1 overflow-y-auto px-4 py-4 space-y-4">
      <!-- Template title -->
      <UInput
        v-model="localTitle"
        :placeholder="$t('myTemplate.titlePlaceholder')"
        size="lg"
        class="w-full"
      />

      <!-- Saved toast -->
      <Transition name="fade">
        <p v-if="showSaved" class="text-sm text-center text-green-500 font-medium">
          {{ $t('myTemplate.saved') }}
        </p>
      </Transition>

      <!-- Slide list -->
      <div v-if="localSlides.length === 0" class="text-center text-muted py-10 text-sm">
        {{ $t('myTemplate.noSlides') }}
      </div>

      <div ref="sortableEl" class="space-y-3">
        <div
          v-for="(slide, index) in localSlides"
          :key="slide.id"
          class="flex items-start gap-3 bg-muted rounded-xl p-3 border border-default"
        >
          <!-- Drag handle -->
          <div class="drag-handle cursor-grab pt-1">
            <GripVertical class="w-5 h-5 text-muted" />
          </div>

          <!-- Slide icon + content -->
          <div class="flex-1 min-w-0">
            <div class="flex items-center gap-2 mb-1">
              <component :is="slideIcon(slide.type)" class="w-4 h-4 text-primary" />
              <span class="text-xs font-semibold text-muted uppercase tracking-wide">
                {{ $t(`myTemplate.slideTypes.${slide.type}`) }}
              </span>
            </div>
            <!-- Prompt text editor for journal_prompt slides -->
            <UInput
              v-if="slide.type === 'journal_prompt'"
              v-model="slide.question"
              :placeholder="$t('myTemplate.promptPlaceholder')"
              size="sm"
              class="w-full"
            />
          </div>

          <!-- Delete button -->
          <button
            class="p-1.5 rounded-lg hover:bg-red-100 dark:hover:bg-red-900/30 text-red-500 shrink-0"
            @click="removeSlide(index)"
          >
            <Trash2 class="w-4 h-4" />
          </button>
        </div>
      </div>

      <!-- Add slide button -->
      <UButton
        variant="outline"
        class="w-full"
        @click="showPicker = true"
      >
        <Plus class="w-4 h-4 mr-2" />
        {{ $t('myTemplate.addSlide') }}
      </UButton>
    </div>

    <!-- Slide type picker modal -->
    <UModal v-model:open="showPicker">
      <template #content>
        <div class="p-4 space-y-3">
          <h2 class="text-base font-semibold text-center mb-4">{{ $t('myTemplate.pickSlideType') }}</h2>
          <button
            v-for="type in SLIDE_TYPES"
            :key="type"
            class="w-full flex items-center gap-3 px-4 py-3 rounded-xl bg-muted hover:bg-accented transition-colors border border-default"
            @click="addSlide(type)"
          >
            <component :is="slideIcon(type)" class="w-5 h-5 text-primary" />
            <span class="font-medium">{{ $t(`myTemplate.slideTypes.${type}`) }}</span>
          </button>
        </div>
      </template>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import { ChevronLeft, GripVertical, Trash2, Plus, BookOpen, Heart, Moon } from 'lucide-vue-next';
import { useSortable } from '@vueuse/integrations/useSortable';
import { useCustomTemplateStore } from '~/stores/stores/custom_template_store';
import type { SlideData } from '~/types/user_journal';

definePageMeta({ layout: 'default' });

const SLIDE_TYPES = ['journal_prompt', 'emotion_log', 'sleep_check'] as const;
type TemplateSlideType = typeof SLIDE_TYPES[number];

const templateStore = useCustomTemplateStore();

const localTitle = ref(templateStore.title || 'My Daily Template');
const localSlides = ref<SlideData[]>(
  templateStore.slideGroups.flatMap(g => g.slides).map(s => ({ ...s }))
);
const saving = ref(false);
const showSaved = ref(false);
const showPicker = ref(false);
const sortableEl = ref<HTMLElement | null>(null);

// Keep localSlides ordered after drag
useSortable(sortableEl, localSlides, {
  handle: '.drag-handle',
  animation: 200,
});

onMounted(async () => {
  if (!templateStore.isLoaded) {
    await templateStore.loadCustomTemplate();
  }
  if (templateStore.isLoaded) {
    localTitle.value = templateStore.title;
    localSlides.value = templateStore.slideGroups.flatMap(g => g.slides).map(s => ({ ...s }));
  }
});

function slideIcon(type: string) {
  if (type === 'emotion_log') return Heart;
  if (type === 'sleep_check') return Moon;
  return BookOpen;
}

function addSlide(type: TemplateSlideType) {
  localSlides.value.push({
    id: crypto.randomUUID(),
    type,
    question: type === 'journal_prompt' ? '' : undefined,
  });
  showPicker.value = false;
}

function removeSlide(index: number) {
  localSlides.value.splice(index, 1);
}

async function handleSave() {
  saving.value = true;
  try {
    // Wrap all slides in a single slide group to match the SlideGroup schema
    const slideGroups = [{
      id: 'custom-group',
      title: localTitle.value,
      description: '',
      position: 0,
      slides: localSlides.value,
    }];
    await templateStore.saveCustomTemplate(localTitle.value, slideGroups);
    showSaved.value = true;
    setTimeout(() => { showSaved.value = false; }, 2500);
  } finally {
    saving.value = false;
  }
}
</script>

<style scoped>
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.4s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>
