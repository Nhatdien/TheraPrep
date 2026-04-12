<template>
  <section class="px-4 py-6 pb-20 lg:pb-0">
    <!-- Header -->
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold lg:text-3xl">{{ $t('learn.library') }}</h1>
      <UButton variant="ghost" size="lg" icon="i-lucide-user" class="rounded-full lg:hidden" />
    </div>

    <!-- Sync Status Banner -->
    <div
      v-if="!journalStore.isOnline"
      class="mb-4 p-3 bg-yellow-500/10 border border-yellow-500/30 rounded-lg flex items-center gap-2">
      <Icon name="i-lucide-wifi-off" class="w-5 h-5 text-yellow-500" />
      <span class="text-sm text-yellow-500">{{ $t('learn.workingOffline') }}</span>
    </div>

    <!-- Loading State -->
    <div v-if="isLoading" class="flex justify-center items-center py-12">
      <Icon name="i-lucide-loader" class="w-8 h-8 animate-spin text-primary" />
    </div>

    <template v-else>
      <!-- Featured Section -->
      <div class="flex flex-col gap-3 mb-8 md:grid md:grid-cols-2">
        <div
          v-for="featured in featuredCollections"
          :key="featured.id"
          class="flex items-center rounded-xl border border-default bg-elevated overflow-hidden cursor-pointer hover:bg-muted hover:shadow-sm transition-all"
          @click="navigateTo(`/learn_and_prepare/collection/${featured.id}`)">
          <div class="w-24 h-20 flex items-center justify-center bg-illus-dark shrink-0">
            <component :is="getFeaturedIllustration(featured.category, featured.title)" class="w-16 h-16" />
          </div>
          <div class="flex-1 px-4 py-3">
            <p class="text-xs text-muted mb-1">{{ $t('learn.featured') }}</p>
            <p class="font-medium">{{ featured.title }}</p>
          </div>
          <Icon name="i-lucide-chevron-right" class="w-5 h-5 text-dimmed mr-4" />
        </div>
      </div>

      <!-- Collections Section -->
      <div class="mb-8">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl font-semibold">{{ $t('learn.collections') }}</h2>
          <NuxtLink to="/learn_and_prepare/collections" class="text-sm text-muted flex items-center gap-1 hover:text-default">
            {{ $t('learn.seeAll') }}
            <Icon name="i-lucide-chevron-right" class="w-4 h-4" />
          </NuxtLink>
        </div>
        
        <!-- Collection Cards (2-col portrait grid) -->
        <div class="grid grid-cols-2 gap-4 xl:grid-cols-3">
          <LearnCollectionCard
            v-for="collection in displayedCollections"
            :key="collection.id"
            :title="collection.title"
            :category="collection.category"
            :chapter-count="collection.slide_groups?.length || 0"
            :progress="getCollectionProgress(collection.id)"
            @click="navigateTo(`/learn_and_prepare/collection/${collection.id}`)"
          />
        </div>
      </div>

      <!-- All Categories Section -->
      <div class="mb-8">
        <h2 class="text-xl font-semibold mb-4">{{ $t('learn.allCategories') }}</h2>
        
        <!-- Category Tabs (Horizontal Scroll) -->
        <div class="flex gap-2 overflow-x-auto pb-3 -mx-4 px-4 scrollbar-hide mb-4">
          <button
            v-for="category in categories"
            :key="category.id"
            class="flex flex-col items-center gap-2 px-4 py-2 rounded-lg shrink-0 transition-colors"
            :class="selectedCategory === category.id ? 'text-highlighted' : 'text-muted hover:text-default'"
            @click="selectedCategory = category.id">
            <component :is="category.icon" class="w-6 h-6" />
            <span class="text-xs whitespace-nowrap">{{ category.label }}</span>
          </button>
        </div>

        <!-- Category Cards Grid (Slide Groups) -->
        <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3 mb-4">
          <div
            v-for="item in categorySlideGroups"
            :key="item.slideGroup.id"
            class="p-4 rounded-xl border border-default bg-elevated cursor-pointer hover:bg-muted hover:shadow-sm transition-all"
            @click="navigateTo(`/learn_and_prepare/collection/${item.collectionId}/${item.slideGroup.id}`)">
            <h3 class="font-medium text-base mb-1">{{ item.slideGroup.title }}</h3>
            <p class="text-xs text-muted">{{ $t('learn.questions', { count: item.slideGroup.slides?.length || 0 }) }}</p>
          </div>
        </div>

        <!-- See All Link -->
        <NuxtLink 
          v-if="categorySlideGroups.length > 0"
          :to="`/learn_and_prepare/category/${selectedCategory}`" 
          class="flex items-center justify-center gap-1 text-sm text-muted hover:text-default">
          {{ $t('learn.seeAllOnCategory', { count: totalCategoryCount, category: selectedCategoryLabel }) }}
          <Icon name="i-lucide-chevron-right" class="w-4 h-4" />
        </NuxtLink>
      </div>
    </template>
  </section>
</template>

<script lang="ts" setup>
import { userJournalStore } from "~/stores/stores/user_journal";
import { useLearnedStore } from "~/stores/stores/user_learned";
import { TOOLKIT_COLLECTION_IDS } from "~/types/therapy_toolkit";
import { getIllustrationComponent } from '~/components/Illustrations/index';
import { 
  CheckSquare, 
  Umbrella, 
  Cloud, 
  Moon,
  Wind,
  CircleDot,
  Heart,
  Brain,
  Sparkles,
  AlertCircle,
  Leaf,
  Sun,
  Feather,
  Users,
  Smile
} from "lucide-vue-next";

const journalStore = userJournalStore();
const learnedStore = useLearnedStore();
const { t } = useI18n();
const isLoading = ref(true);
const selectedCategory = ref("check-ins");

// Load templates and progress on mount
onMounted(async () => {
  try {
    console.log("calling get templates");
    await journalStore.getAllTemplates();
    // Load learned progress
    learnedStore.setOnline(journalStore.isOnline);
    await learnedStore.loadFromLocal();
    if (journalStore.isOnline) {
      await learnedStore.fullSync();
    }
  } catch (error) {
    console.error("Error loading templates:", error);
  } finally {
    isLoading.value = false;
  }
});

// Featured collections (first 2 learn-type)
const featuredCollections = computed(() => {
  return learnCollections.value.slice(0, 2);
});

// Learn-type collections (for Collections section) — exclude Toolkit collections
const learnCollections = computed(() => {
  return journalStore.templates.filter(
    t => t.type === 'learn' && !TOOLKIT_COLLECTION_IDS.includes(t.id)
  );
});

// Journal-type templates (for Categories section) — exclude Toolkit collections
const journalTemplates = computed(() => {
  return journalStore.templates.filter(
    t => (t.type === 'journal' || !t.type) && !TOOLKIT_COLLECTION_IDS.includes(t.id)
  );
});

// Display collections (for horizontal scroll, max 5)
const displayedCollections = computed(() => {
  return learnCollections.value.slice(0, 5);
});

// Category icon mapping
const categoryIconMap: Record<string, any> = {
  // Check-ins & Daily
  "check-in": CheckSquare,
  "check-ins": CheckSquare,
  "daily": Umbrella,
  "essential": Umbrella,
  "daily-essentials": Umbrella,
  // Well-being & Mental Health
  "well-being": Cloud,
  "wellbeing": Cloud,
  "wellness": Cloud,
  "sos": Cloud,
  "mental_health": Brain,
  "mental-health": Brain,
  // Sleep
  "bedtime": Moon,
  "sleep": Moon,
  "night": Moon,
  // Therapy & Journaling
  "therapy": Feather,
  "prepare": Feather,
  "journal": Feather,
  // Mindfulness & Meditation
  "mindfulness": Wind,
  "meditation": CircleDot,
  // Anxiety
  "anxiety": AlertCircle,
  "worry": AlertCircle,
  // Relationships
  "relationship": Heart,
  "relationships": Heart,
  "connection": Users,
  // Gratitude & Positivity
  "gratitude": Sparkles,
  "positivity": Sun,
  // Emotions
  "emotion": Brain,
  "emotions": Brain,
  // Self-care
  "self_care": Heart,
  "self-care": Heart,
  "compassion": Smile,
};

// Get icon for a category
const getCategoryIcon = (category: string) => {
  const lower = category?.toLowerCase() || "";
  for (const [key, icon] of Object.entries(categoryIconMap)) {
    if (lower.includes(key)) return icon;
  }
  return Leaf; // Default icon
};

// Translate category name using i18n lookup
const categoryKeyMap: Record<string, string> = {
  'check-in': 'checkIns', 'check-ins': 'checkIns',
  'daily': 'daily', 'essential': 'daily', 'daily-essentials': 'daily',
  'well-being': 'wellBeing', 'wellbeing': 'wellBeing', 'wellness': 'wellBeing', 'sos': 'wellBeing',
  'mental_health': 'mentalHealth', 'mental-health': 'mentalHealth',
  'bedtime': 'sleep', 'sleep': 'sleep', 'night': 'sleep',
  'therapy': 'therapy', 'prepare': 'therapy',
  'journal': 'journal',
  'mindfulness': 'mindfulness', 'meditation': 'meditation',
  'anxiety': 'anxiety', 'worry': 'anxiety',
  'relationship': 'relationships', 'relationships': 'relationships', 'connection': 'relationships',
  'gratitude': 'gratitude', 'positivity': 'positivity',
  'emotion': 'emotions', 'emotions': 'emotions',
  'self_care': 'selfCare', 'self-care': 'selfCare', 'compassion': 'selfCare',
  'morning': 'morning', 'evening': 'evening',
  'stress': 'stress', 'mood': 'mood',
};

const getCategoryLabel = (rawCategory: string) => {
  const lower = rawCategory.toLowerCase().replace(/\s+/g, '-');
  const key = categoryKeyMap[lower];
  if (key) {
    const translated = t(`learn.categories.${key}`);
    if (translated !== `learn.categories.${key}`) return translated;
  }
  return rawCategory;
};

// Dynamic categories from journal-type templates — count slide groups, not collections
const categories = computed(() => {
  const uniqueCategories = new Map<string, { id: string; label: string; icon: any; count: number }>();
  
  journalTemplates.value.forEach(template => {
    const category = template.category?.trim();
    if (category) {
      const id = category.toLowerCase().replace(/\s+/g, '-');
      const slideGroupCount = template.slide_groups?.length || 0;
      if (!uniqueCategories.has(id)) {
        uniqueCategories.set(id, {
          id,
          label: getCategoryLabel(category),
          icon: getCategoryIcon(category),
          count: slideGroupCount,
        });
      } else {
        uniqueCategories.get(id)!.count += slideGroupCount;
      }
    }
  });
  
  return Array.from(uniqueCategories.values());
});

// Set default selected category when categories load
watch(categories, (newCategories) => {
  if (newCategories.length > 0 && !newCategories.find(c => c.id === selectedCategory.value)) {
    selectedCategory.value = newCategories[0].id;
  }
}, { immediate: true });

const selectedCategoryLabel = computed(() => {
  return categories.value.find(c => c.id === selectedCategory.value)?.label || "";
});

// Flatten journal-type templates into individual slide groups for the selected category
const categorySlideGroups = computed(() => {
  const selectedCat = categories.value.find(c => c.id === selectedCategory.value);
  if (!selectedCat) return [];
  
  const result: { slideGroup: any; collectionId: string; collectionTitle: string }[] = [];
  
  journalTemplates.value.forEach(template => {
    const templateCategory = template.category?.toLowerCase().replace(/\s+/g, '-');
    if (templateCategory === selectedCategory.value && template.slide_groups) {
      const groups = typeof template.slide_groups === 'string'
        ? JSON.parse(template.slide_groups)
        : template.slide_groups;
      
      groups.forEach((sg: any) => {
        result.push({
          slideGroup: sg,
          collectionId: template.id,
          collectionTitle: template.title,
        });
      });
    }
  });
  
  return result.slice(0, 6);
});

const totalCategoryCount = computed(() => {
  // Count all slide groups in the selected category across all journal-type templates
  let count = 0;
  journalTemplates.value.forEach(template => {
    const templateCategory = template.category?.toLowerCase().replace(/\s+/g, '-');
    if (templateCategory === selectedCategory.value) {
      const groups = typeof template.slide_groups === 'string'
        ? JSON.parse(template.slide_groups)
        : template.slide_groups;
      count += groups?.length || 0;
    }
  });
  return count;
});

// Mindful exercises (static for now)
const mindfulExercises = [
  { id: "breathing", title: "Breathing", icon: Wind },
  { id: "meditation", title: "Meditation", icon: CircleDot },
];

// Featured illustration resolver
const getFeaturedIllustration = (category: string, title: string) =>
  getIllustrationComponent(`${category || ''} ${title || ''}`);

const getCollectionProgress = (collectionId: string) => {
  const collection = learnCollections.value.find(c => c.id === collectionId);
  const totalSlideGroups = collection?.slide_groups?.length || 0;
  if (totalSlideGroups === 0) return 0;
  return learnedStore.getProgress(collectionId, totalSlideGroups);
};</script>

<style scoped>
.scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
}
.scrollbar-hide::-webkit-scrollbar {
  display: none;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
