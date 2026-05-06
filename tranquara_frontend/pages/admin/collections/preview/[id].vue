<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <div class="flex items-center gap-3">
        <UButton icon="i-heroicons-arrow-left" variant="ghost" size="sm" @click="router.back()" />
        <h1 class="text-xl font-bold">Preview: {{ template?.title }}</h1>
      </div>
      <div class="flex gap-2">
        <USelect v-model="lang" :items="langOptions" size="sm" class="w-32" />
        <UButton variant="outline" icon="i-heroicons-pencil-square" :to="`/admin/collections/${id}`">
          Back to Editor
        </UButton>
      </div>
    </div>

    <div v-if="!template" class="text-center text-gray-500 py-12">Loading...</div>

    <!-- Preview Frame -->
    <div v-else class="flex justify-center">
      <div class="w-full max-w-sm border border-gray-200 dark:border-gray-700 rounded-2xl overflow-hidden shadow-lg bg-white dark:bg-gray-900">
        <!-- Group selector -->
        <div class="px-4 py-3 border-b border-gray-100 dark:border-gray-800">
          <USelect v-model="activeGroupIdx" :items="groupOptions" size="sm" />
        </div>

        <!-- Slide content -->
        <div v-if="activeGroup" class="p-5 min-h-[400px]">
          <div class="flex items-center justify-between mb-4">
            <h3 class="font-semibold text-sm">{{ getLocalizedText(activeGroup, 'title') }}</h3>
            <span class="text-xs text-gray-400">Slide {{ activeSlideIdx + 1 }} / {{ activeGroup.slides.length }}</span>
          </div>

          <div v-if="activeSlide" class="space-y-4">
            <!-- Render based on type -->
            <div v-if="activeSlide.type === 'emotion_log'" class="space-y-3">
              <p class="text-sm">{{ getLocalizedText(activeSlide, 'question') }}</p>
              <div class="flex items-center gap-2">
                <span class="text-xs">😢</span>
                <div class="flex-1 h-2 bg-gray-200 dark:bg-gray-700 rounded-full">
                  <div class="h-2 bg-primary-500 rounded-full" style="width: 70%"></div>
                </div>
                <span class="text-xs">😊</span>
              </div>
              <div v-if="activeSlide.config?.labels" class="text-center text-xs text-gray-500">
                {{ activeSlide.config.labels[6] }} (7/10)
              </div>
            </div>

            <div v-else-if="activeSlide.type === 'sleep_check'" class="space-y-3">
              <p class="text-sm">{{ getLocalizedText(activeSlide, 'question') }}</p>
              <div class="flex items-center gap-2">
                <span class="text-xs">{{ activeSlide.config?.min || 0 }}h</span>
                <div class="flex-1 h-2 bg-gray-200 dark:bg-gray-700 rounded-full">
                  <div class="h-2 bg-blue-500 rounded-full" style="width: 60%"></div>
                </div>
                <span class="text-xs">{{ activeSlide.config?.max || 12 }}h</span>
              </div>
            </div>

            <div v-else-if="activeSlide.type === 'journal_prompt'" class="space-y-3">
              <p class="text-sm font-medium">{{ getLocalizedText(activeSlide, 'question') }}</p>
              <div class="border border-gray-200 dark:border-gray-700 rounded-lg p-3 min-h-[100px] text-xs text-gray-400 italic">
                Tap to start writing...
              </div>
              <div v-if="activeSlide.config?.allowAI" class="flex items-center gap-1 text-xs text-primary-500">
                <UIcon name="i-heroicons-sparkles" class="w-3 h-3" />
                AI follow-up available
              </div>
            </div>

            <div v-else-if="activeSlide.type === 'doc'" class="space-y-2">
              <h4 v-if="activeSlide.title" class="font-medium text-sm">{{ getLocalizedText(activeSlide, 'title') }}</h4>
              <div class="text-sm prose prose-sm dark:prose-invert max-w-none" v-html="getLocalizedText(activeSlide, 'content')" />
            </div>

            <div v-else-if="activeSlide.type === 'further_reading'" class="space-y-2">
              <p class="text-xs text-gray-500 font-medium uppercase">Further Reading</p>
              <div v-for="link in (activeSlide as any).links" :key="link.url" class="border border-gray-100 dark:border-gray-700 rounded p-2">
                <p class="text-sm font-medium text-primary-600">{{ link.title }}</p>
                <p class="text-xs text-gray-400 truncate">{{ link.url }}</p>
              </div>
            </div>

            <div v-else-if="activeSlide.type === 'cta'" class="text-center space-y-3">
              <p v-if="activeSlide.title" class="text-sm font-medium">{{ getLocalizedText(activeSlide, 'title') }}</p>
              <UButton color="primary" size="sm">{{ activeSlide.config?.buttonText || 'Start' }}</UButton>
            </div>

            <div v-else class="text-sm text-gray-500 italic">
              [{{ activeSlide.type }}] {{ getLocalizedText(activeSlide, 'question') || getLocalizedText(activeSlide, 'title') || 'Preview not available' }}
            </div>
          </div>
        </div>

        <!-- Navigation -->
        <div class="px-4 py-3 border-t border-gray-100 dark:border-gray-800 flex justify-between">
          <UButton size="xs" variant="ghost" :disabled="activeSlideIdx === 0" @click="activeSlideIdx--">
            ← Back
          </UButton>
          <UButton size="xs" variant="ghost" :disabled="!activeGroup || activeSlideIdx >= activeGroup.slides.length - 1" @click="activeSlideIdx++">
            Next →
          </UButton>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useAdminStore } from '~/stores/stores/admin_store';
import type { AdminJournalTemplate } from '~/stores/admin_templates';
import type { SlideData, SlideGroup } from '~/types/user_journal';

definePageMeta({
  layout: 'admin' as any,
  middleware: ['admin' as any],
});

const route = useRoute();
const router = useRouter();
const adminStore = useAdminStore();

const id = computed(() => route.params.id as string);
const template = ref<AdminJournalTemplate | null>(null);
const lang = ref('en');
const activeGroupIdx = ref('0');
const activeSlideIdx = ref(0);

const langOptions = [
  { label: 'English', value: 'en' },
  { label: 'Vietnamese', value: 'vi' },
];

onMounted(async () => {
  const t = await adminStore.loadTemplate(id.value);
  template.value = t;
});

const groupOptions = computed(() => {
  if (!template.value) return [];
  const groups = lang.value === 'vi' && template.value.slide_groups_vi?.length
    ? template.value.slide_groups_vi
    : template.value.slide_groups;
  return groups.map((g, i) => ({ label: `${i + 1}. ${g.title}`, value: String(i) }));
});

const activeGroup = computed((): SlideGroup | null => {
  if (!template.value) return null;
  const groups = lang.value === 'vi' && template.value.slide_groups_vi?.length
    ? template.value.slide_groups_vi
    : template.value.slide_groups;
  return groups[Number(activeGroupIdx.value)] || null;
});

const activeSlide = computed((): SlideData | null => {
  return activeGroup.value?.slides[activeSlideIdx.value] || null;
});

watch(activeGroupIdx, () => { activeSlideIdx.value = 0; });

function getLocalizedText(obj: any, field: string): string {
  if (lang.value === 'vi') {
    const viField = `${field}_vi`;
    if (obj[viField]) return obj[viField];
  }
  return obj[field] || '';
}
</script>
