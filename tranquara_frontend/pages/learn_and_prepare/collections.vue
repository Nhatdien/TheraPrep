<template>
  <section class="min-h-screen pb-20 lg:pb-0">
    <!-- Desktop Breadcrumbs -->
    <div class="px-4 pt-4">
      <DesktopBreadcrumb :items="breadcrumbs" />
    </div>

    <!-- Back Button (mobile) -->
    <div class="px-4 pt-4 lg:hidden">
      <UButton 
        variant="ghost" 
        size="lg" 
        icon="i-lucide-chevron-left" 
        class="p-0"
        @click="navigateTo('/learn_and_prepare')" 
      />
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="flex justify-center items-center py-24">
      <Icon name="i-lucide-loader" class="w-8 h-8 animate-spin text-primary" />
    </div>

    <template v-else>
      <!-- Header -->
      <div class="px-6 pt-8 pb-8 text-center">
        <h1 class="text-3xl font-bold mb-3">{{ $t('learnSub.collections') }}</h1>
        <p class="text-muted text-sm leading-relaxed max-w-sm mx-auto">
          {{ $t('learnSub.collectionsDescription') }}
        </p>
      </div>

      <!-- Learn Collections -->
      <div class="px-4 grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-4">
        <LearnCollectionCard
          v-for="collection in learnCollections"
          :key="collection.id"
          :title="collection.title"
          :category="collection.category"
          :chapter-count="collection.slide_groups?.length || 0"
          :progress="getCollectionProgress(collection.id)"
          @click="navigateTo(`/learn_and_prepare/collection/${collection.id}`)"
        />
      </div>

      <!-- Journal Templates Section -->
      <div v-if="journalCollections.length > 0" class="mt-10">
        <div class="px-6 pb-6 text-center">
          <h2 class="text-2xl font-bold mb-2">{{ $t('learnSub.journalTemplates', 'Journal Templates') }}</h2>
          <p class="text-muted text-sm leading-relaxed max-w-sm mx-auto">
            {{ $t('learnSub.journalTemplatesDescription', 'Ready-to-use journaling prompts for daily reflection and self-care.') }}
          </p>
        </div>

        <div class="px-4 grid grid-cols-2 gap-4 md:grid-cols-3 lg:grid-cols-4">
          <LearnCollectionCard
            v-for="collection in journalCollections"
            :key="collection.id"
            :title="collection.title"
            :category="collection.category"
            :chapter-count="collection.slide_groups?.length || 0"
            @click="navigateTo(`/learn_and_prepare/collection/${collection.id}`)"
          />
        </div>
      </div>
    </template>
  </section>
</template>

<script lang="ts" setup>
import type { BreadcrumbItem } from '@nuxt/ui'
import { userJournalStore } from "~/stores/stores/user_journal";
import { useLearnedStore } from "~/stores/stores/user_learned";
import { 
  Feather, 
  Moon, 
  Leaf, 
  Cloud, 
  Sun,
  Heart,
  Brain,
  Sparkles,
  AlertCircle,
  Wind,
  Smile,
  CheckSquare
} from "lucide-vue-next";

const { t } = useI18n();
const journalStore = userJournalStore();
const learnedStore = useLearnedStore();
const isLoading = ref(true);

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  { label: t('nav.library'), icon: 'i-lucide-book-open', to: '/learn_and_prepare' },
  { label: t('learnSub.collections') },
])

// Load templates and progress on mount
onMounted(async () => {
  try {
    await Promise.all([
      journalStore.getAllTemplates(),
      learnedStore.loadFromLocal(),
    ]);
  } catch (error) {
    console.error("Error loading templates:", error);
  } finally {
    isLoading.value = false;
  }
});

// Learn-type collections
const learnCollections = computed(() => {
  return journalStore.templates.filter(t => t.type === 'learn');
});

// Journal-type collections (template packs)
const journalCollections = computed(() => {
  return journalStore.templates.filter(t => t.type === 'journal');
});

// Combined for progress tracking
const allCollections = computed(() => {
  return [...learnCollections.value, ...journalCollections.value];
});

// Get icon based on category or title keywords
const getCollectionIcon = (category: string, title: string) => {
  const text = `${category || ""} ${title || ""}`.toLowerCase();
  
  // Sleep
  if (text.includes("sleep") || text.includes("night") || text.includes("bedtime")) return Moon;
  // Journaling
  if (text.includes("journal")) return Feather;
  // Anxiety
  if (text.includes("anxiety") || text.includes("worry")) return AlertCircle;
  // Stress & Mental Health
  if (text.includes("stress") || text.includes("mental")) return Cloud;
  // ADHD & Mind
  if (text.includes("adhd") || text.includes("mind") || text.includes("emotion")) return Brain;
  // Relationships
  if (text.includes("love") || text.includes("relationship")) return Heart;
  // Gratitude & Joy
  if (text.includes("gratitude") || text.includes("happy") || text.includes("joy")) return Sparkles;
  // Therapy
  if (text.includes("therapy") || text.includes("preparation")) return Feather;
  // Mindfulness
  if (text.includes("mindful")) return Wind;
  // Self-compassion
  if (text.includes("compassion") || text.includes("self-care") || text.includes("self_care")) return Smile;
  // Check-ins
  if (text.includes("check") || text.includes("daily") || text.includes("reflection")) return CheckSquare;
  // Positivity
  if (text.includes("positiv")) return Sun;
  
  return Feather; // Default icon
};

// Get collection progress from learned store
const getCollectionProgress = (collectionId: string) => {
  const collection = allCollections.value.find(c => c.id === collectionId);
  const totalSlideGroups = collection?.slide_groups?.length || 0;
  if (totalSlideGroups === 0) return 0;
  return learnedStore.getProgress(collectionId, totalSlideGroups);
};
</script>
