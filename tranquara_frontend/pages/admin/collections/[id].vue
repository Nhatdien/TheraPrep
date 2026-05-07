<template>
  <div class="max-w-6xl mx-auto">
    <!-- Header -->
    <div class="flex items-center justify-between mb-8">
      <div class="flex items-center gap-4">
        <UButton icon="i-heroicons-arrow-left" variant="ghost" to="/admin/collections" />
        <div>
          <h1 class="text-2xl font-bold">{{ isNew ? 'New Collection' : `Edit: ${form.title}` }}</h1>
        </div>
      </div>
      <div class="flex gap-3">
        <UButton v-if="!isNew" variant="outline" icon="i-heroicons-eye" :to="`/admin/collections/preview/${id}`">
          Preview
        </UButton>
        <UButton color="primary" icon="i-heroicons-check" :loading="saving" @click="handleSave">
          Save
        </UButton>
      </div>
    </div>

    <!-- Form -->
    <div class="space-y-6">
      <!-- Collection Details Card -->
      <div class="bg-white dark:bg-gray-900 rounded-2xl border border-gray-200 dark:border-gray-800 shadow-sm overflow-hidden">
        <!-- Card Header -->
        <div class="flex items-center justify-between px-6 py-4 border-b border-gray-100 dark:border-gray-800 bg-gray-50/50 dark:bg-gray-800/30">
          <div class="flex items-center gap-2">
            <UIcon name="i-heroicons-document-text" class="text-primary-500 w-5 h-5" />
            <h2 class="font-semibold">Collection Details</h2>
          </div>
          <USwitch v-model="showVi" size="sm" label="Show Vietnamese" />
        </div>

        <div class="p-6 space-y-6">
          <!-- Title + Description side by side when VI shown, stacked otherwise -->
          <div class="grid gap-5" :class="showVi ? 'lg:grid-cols-2' : ''">
            <!-- EN Column -->
            <div class="space-y-5">
              <div v-if="showVi" class="flex items-center gap-2 pb-2 border-b border-gray-100 dark:border-gray-800">
                <span class="text-xs font-bold text-gray-400 uppercase tracking-wider">🇬🇧 English</span>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">
                  Title <span class="text-red-500">*</span>
                </label>
                <UInput
                  v-model="form.title"
                  placeholder="e.g. Managing Anxiety with Mindfulness"
                  size="lg"
                  :color="errors.title ? 'error' : undefined"
                  icon="i-heroicons-pencil"
                />
                <p v-if="errors.title" class="text-xs text-red-500 mt-1">{{ errors.title }}</p>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Description</label>
                <UTextarea
                  v-model="form.description"
                  placeholder="A brief summary of what users will learn or do in this collection..."
                  :rows="4"
                  size="lg"
                />
              </div>
            </div>
            <!-- VI Column -->
            <div v-if="showVi" class="space-y-5 rounded-xl bg-blue-50/40 dark:bg-blue-950/20 border border-blue-100 dark:border-blue-900/40 p-5">
              <div class="flex items-center gap-2 pb-2 border-b border-blue-100 dark:border-blue-900/40">
                <span class="text-xs font-bold text-blue-500 uppercase tracking-wider">🇻🇳 Vietnamese</span>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Title (VI)</label>
                <UInput v-model="form.title_vi" placeholder="Tiêu đề bộ sưu tập..." size="lg" />
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Description (VI)</label>
                <UTextarea v-model="form.description_vi" placeholder="Mô tả ngắn gọn..." :rows="4" size="lg" />
              </div>
            </div>
          </div>

          <!-- Metadata Row -->
          <div class="grid grid-cols-1 md:grid-cols-3 gap-5 pt-5 border-t border-gray-100 dark:border-gray-800">
            <!-- Type -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">
                Type <span class="text-red-500">*</span>
              </label>
              <USelect
                v-model="form.type"
                :items="typeOptions"
                size="lg"
                :color="errors.type ? 'error' : undefined"
                icon="i-heroicons-squares-2x2"
              />
              <p v-if="errors.type" class="text-xs text-red-500 mt-1">{{ errors.type }}</p>
            </div>
            <!-- Category -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">
                Category <span class="text-red-500">*</span>
              </label>
              <USelect
                v-model="form.category"
                :items="allCategoryOptions"
                size="lg"
                :color="errors.category ? 'error' : undefined"
                icon="i-heroicons-tag"
              />
              <div v-if="form.category === '__custom__'" class="mt-2">
                <UInput
                  v-model="customCategory"
                  placeholder="e.g. self_compassion"
                  size="lg"
                  icon="i-heroicons-plus"
                  @blur="applyCustomCategory"
                  @keyup.enter="applyCustomCategory"
                />
              </div>
              <p v-if="errors.category" class="text-xs text-red-500 mt-1">{{ errors.category }}</p>
            </div>
            <!-- Status -->
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1.5">Status</label>
              <div class="flex items-center h-[42px] gap-4 px-4 rounded-lg border border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800/50">
                <USwitch
                  v-model="form.is_active"
                  :color="form.is_active ? 'success' : 'neutral'"
                />
                <span class="text-sm font-medium" :class="form.is_active ? 'text-green-600 dark:text-green-400' : 'text-gray-500'">
                  {{ form.is_active ? 'Active' : 'Inactive' }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Slide Groups Card -->
      <div class="bg-white dark:bg-gray-900 rounded-2xl border border-gray-200 dark:border-gray-800 shadow-sm overflow-hidden">
        <!-- Card Header -->
        <div class="flex items-center justify-between px-6 py-4 border-b border-gray-100 dark:border-gray-800 bg-gray-50/50 dark:bg-gray-800/30">
          <div class="flex items-center gap-2">
            <UIcon name="i-heroicons-rectangle-stack" class="text-primary-500 w-5 h-5" />
            <h2 class="font-semibold">Slide Groups</h2>
            <UBadge v-if="form.slide_groups.length" color="neutral" variant="subtle" size="xs">
              {{ form.slide_groups.length }}
            </UBadge>
          </div>
          <UButton icon="i-heroicons-plus" color="primary" variant="soft" size="sm" @click="addSlideGroup">
            Add Group
          </UButton>
        </div>

        <div class="p-6">
          <p v-if="errors.slide_groups" class="text-sm text-red-500 mb-4 flex items-center gap-1.5">
            <UIcon name="i-heroicons-exclamation-circle" class="w-4 h-4" />
            {{ errors.slide_groups }}
          </p>

          <!-- Empty state -->
          <div v-if="form.slide_groups.length === 0" class="flex flex-col items-center justify-center py-12 text-center">
            <div class="w-14 h-14 rounded-full bg-gray-100 dark:bg-gray-800 flex items-center justify-center mb-4">
              <UIcon name="i-heroicons-rectangle-stack" class="w-7 h-7 text-gray-400" />
            </div>
            <p class="text-gray-500 font-medium mb-1">No slide groups yet</p>
            <p class="text-sm text-gray-400 mb-4">Add a group to start building your collection</p>
            <UButton icon="i-heroicons-plus" variant="outline" size="sm" @click="addSlideGroup">Add First Group</UButton>
          </div>

          <div ref="slideGroupsContainer" class="space-y-3">
            <div
              v-for="(group, gIdx) in form.slide_groups"
              :key="group.id"
              class="border border-gray-200 dark:border-gray-700 rounded-xl overflow-hidden"
            >
              <!-- Group Header -->
              <div class="flex items-center gap-3 px-4 py-3 bg-gray-50 dark:bg-gray-800/60">
                <span class="drag-handle-group cursor-grab text-gray-300 hover:text-gray-500 dark:text-gray-600 dark:hover:text-gray-400 text-lg select-none">⠿</span>
                <div class="flex items-center justify-center w-6 h-6 rounded-full bg-primary-100 dark:bg-primary-900/30 text-primary-600 dark:text-primary-400 text-xs font-bold shrink-0">
                  {{ gIdx + 1 }}
                </div>
                <input
                  v-model="group.title"
                  class="flex-1 text-sm font-semibold bg-transparent border-none outline-none placeholder-gray-400 dark:placeholder-gray-600 dark:text-gray-200"
                  placeholder="Group title..."
                />
                <UButton
                  :icon="collapsedGroups.has(group.id) ? 'i-heroicons-chevron-right' : 'i-heroicons-chevron-down'"
                  size="xs"
                  variant="ghost"
                  color="neutral"
                  @click="toggleCollapse(group.id)"
                />
                <UButton icon="i-heroicons-trash" size="xs" variant="ghost" color="error" @click="removeSlideGroup(gIdx)" />
              </div>

              <!-- Group Body (Collapsible) -->
              <div v-show="!collapsedGroups.has(group.id)" class="p-4 space-y-4">
                <div class="grid gap-3" :class="showVi ? 'lg:grid-cols-2' : ''">
                  <UInput v-model="group.description" placeholder="Optional group description..." size="sm" icon="i-heroicons-information-circle" />
                  <UInput v-if="showVi" v-model="getViGroup(gIdx).description" placeholder="Mô tả nhóm (VI)..." size="sm" />
                </div>

                <!-- Slides list -->
                <div class="rounded-lg border border-gray-100 dark:border-gray-700/50 overflow-hidden">
                  <div class="flex items-center justify-between px-3 py-2 bg-gray-50 dark:bg-gray-800/40 border-b border-gray-100 dark:border-gray-700/50">
                    <span class="text-xs font-semibold text-gray-500 uppercase tracking-wider">
                      Slides
                      <span class="ml-1 px-1.5 py-0.5 rounded-full bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-400 text-[10px] font-bold">{{ group.slides.length }}</span>
                    </span>
                    <UButton icon="i-heroicons-plus" size="xs" variant="ghost" color="primary" @click="addSlide(gIdx)">
                      Add Slide
                    </UButton>
                  </div>

                  <!-- Empty slides state -->
                  <div v-if="group.slides.length === 0" class="px-4 py-6 text-center text-sm text-gray-400">
                    No slides yet — click Add Slide to start
                  </div>

                  <div :ref="el => setSlidesRef(gIdx, el)">
                    <div
                      v-for="(slide, sIdx) in group.slides"
                      :key="slide.id"
                      class="flex items-center gap-3 px-4 py-2.5 border-b border-gray-100 dark:border-gray-700/50 last:border-0 hover:bg-gray-50 dark:hover:bg-gray-800/30 transition-colors group/slide"
                    >
                      <span class="drag-handle-slide cursor-grab text-gray-300 hover:text-gray-500 select-none">⠿</span>
                      <UBadge :color="(slideTypeColor(slide.type) as any)" variant="subtle" size="sm" class="w-[110px] justify-center shrink-0">
                        {{ slideTypeLabel(slide.type) }}
                      </UBadge>
                      <span class="flex-1 text-sm text-gray-600 dark:text-gray-400 truncate">
                        {{ slide.question || slide.title || slide.content?.slice(0, 70) || '(no content)' }}
                      </span>
                      <div class="flex gap-1 opacity-0 group-hover/slide:opacity-100 transition-opacity">
                        <UButton icon="i-heroicons-pencil-square" size="xs" variant="ghost" @click="editSlide(gIdx, sIdx)" />
                        <UButton icon="i-heroicons-trash" size="xs" variant="ghost" color="error" @click="removeSlide(gIdx, sIdx)" />
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Slide Editor Modal -->
    <UModal v-model:open="slideModalOpen" :ui="{ content: 'sm:max-w-3xl' }">
      <template #content>
        <div class="p-6 max-h-[85vh] overflow-y-auto">
          <div class="flex items-center justify-between mb-6">
            <h3 class="text-xl font-semibold">{{ editingSlideIsNew ? 'Add Slide' : 'Edit Slide' }}</h3>
            <UBadge v-if="editingSlide.type" :color="(slideTypeColor(editingSlide.type) as any)" variant="subtle" size="lg">
              {{ slideTypeLabel(editingSlide.type) }}
            </UBadge>
          </div>

          <div class="space-y-6">
            <div class="grid grid-cols-2 gap-4">
              <UFormField label="Slide ID">
                <UInput v-model="editingSlide.id" placeholder="slide-id" size="lg" disabled />
              </UFormField>
              <UFormField label="Type">
                <USelect v-model="editingSlide.type" :items="slideTypeOptions" size="lg" />
              </UFormField>
            </div>

            <!-- Divider -->
            <div class="border-t border-gray-200 dark:border-gray-700" />

            <!-- Type-specific fields -->
            <div class="min-h-[200px]">
              <AdminSlideEmotionLog v-if="editingSlide.type === 'emotion_log'" v-model="editingSlide" :show-vi="showVi" />
              <AdminSlideSleepCheck v-else-if="editingSlide.type === 'sleep_check'" v-model="editingSlide" :show-vi="showVi" />
              <AdminSlideJournalPrompt v-else-if="editingSlide.type === 'journal_prompt'" v-model="editingSlide" :show-vi="showVi" />
              <AdminSlideDoc v-else-if="editingSlide.type === 'doc'" v-model="editingSlide" :show-vi="showVi" />
              <AdminSlideFurtherReading v-else-if="editingSlide.type === 'further_reading'" v-model="editingSlide" :show-vi="showVi" />
              <AdminSlideCta v-else-if="editingSlide.type === 'cta'" v-model="editingSlide" :show-vi="showVi" />
              <AdminSlideChecklist v-else-if="editingSlide.type === 'checklist_input'" v-model="editingSlide" :show-vi="showVi" />
              <AdminSlideQuestionnaire v-else-if="editingSlide.type === 'questionnaire'" v-model="editingSlide" :show-vi="showVi" />
              <AdminSlideCompletion v-else-if="editingSlide.type === 'completion'" v-model="editingSlide" :show-vi="showVi" />
              <AdminSlideGeneric v-else v-model="editingSlide" :show-vi="showVi" />
            </div>
          </div>

          <div class="flex justify-end gap-3 mt-8 pt-4 border-t border-gray-200 dark:border-gray-700">
            <UButton variant="outline" size="lg" @click="slideModalOpen = false">Cancel</UButton>
            <UButton color="primary" size="lg" @click="saveSlide">{{ editingSlideIsNew ? 'Add Slide' : 'Save Changes' }}</UButton>
          </div>
        </div>
      </template>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import Sortable from 'sortablejs';
import { useAdminStore } from '~/stores/stores/admin_store';
import type { SlideData, SlideGroup } from '~/types/user_journal';
import type { CreateUpdateTemplateRequest } from '~/stores/admin_templates';

definePageMeta({
  layout: 'admin' as any,
  middleware: ['admin' as any],
});

const route = useRoute();
const router = useRouter();
const adminStore = useAdminStore();
const toast = useToast();

const id = computed(() => route.params.id as string);
const isNew = computed(() => id.value === 'new');
const saving = ref(false);
const showVi = ref(false);
const collapsedGroups = ref<Set<string>>(new Set());

// Form state
const form = reactive<{
  title: string;
  title_vi: string;
  description: string;
  description_vi: string;
  type: string;
  category: string;
  is_active: boolean;
  slide_groups: SlideGroup[];
  slide_groups_vi: SlideGroup[];
}>({
  title: '',
  title_vi: '',
  description: '',
  description_vi: '',
  type: 'learn',
  category: 'self_care',
  is_active: true,
  slide_groups: [],
  slide_groups_vi: [],
});

const errors = reactive<Record<string, string>>({});

// Slide modal state
const slideModalOpen = ref(false);
const editingSlide = ref<SlideData>({ id: '', type: 'journal_prompt' });
const editingSlideIsNew = ref(false);
const editingGroupIdx = ref(0);
const editingSlideIdx = ref(0);

// Options
const typeOptions = [
  { label: 'Learn', value: 'learn' },
  { label: 'Journal', value: 'journal' },
];

const customCategory = ref('');

const categoryOptions = [
  { label: 'Self Care', value: 'self_care' },
  { label: 'Mental Health', value: 'mental_health' },
  { label: 'Therapy Prep', value: 'therapy_prep' },
  { label: 'Anxiety', value: 'anxiety' },
  { label: 'Emotions', value: 'emotions' },
  { label: 'Gratitude', value: 'gratitude' },
  { label: 'Mindfulness', value: 'mindfulness' },
  { label: 'Relationships', value: 'relationships' },
  { label: 'Sleep', value: 'sleep' },
  { label: 'Stress Management', value: 'stress_management' },
  { label: 'Communication', value: 'communication' },
  { label: 'Self Compassion', value: 'self_compassion' },
];

const allCategoryOptions = computed(() => [
  ...categoryOptions,
  { label: '+ Create New Category', value: '__custom__' },
]);

function applyCustomCategory() {
  if (customCategory.value.trim()) {
    const slug = customCategory.value.trim().toLowerCase().replace(/\s+/g, '_');
    form.category = slug;
    customCategory.value = '';
  }
}

const slideTypeOptions = [
  { label: 'Emotion Log', value: 'emotion_log' },
  { label: 'Sleep Check', value: 'sleep_check' },
  { label: 'Journal Prompt', value: 'journal_prompt' },
  { label: 'Document', value: 'doc' },
  { label: 'Further Reading', value: 'further_reading' },
  { label: 'Call to Action', value: 'cta' },
  { label: 'Date Picker', value: 'date_picker' },
  { label: 'Star Rating', value: 'star_rating' },
  { label: 'Checklist', value: 'checklist_input' },
  { label: 'Questionnaire', value: 'questionnaire' },
  { label: 'Completion', value: 'completion' },
];

// Load existing template
onMounted(async () => {
  if (!isNew.value) {
    try {
      const template = await adminStore.loadTemplate(id.value);
      if (template) {
        form.title = template.title;
        form.title_vi = template.title_vi || '';
        form.description = template.description || '';
        form.description_vi = template.description_vi || '';
        form.type = template.type;
        form.category = template.category;
        form.is_active = template.is_active;
        form.slide_groups = JSON.parse(JSON.stringify(template.slide_groups || []));
        form.slide_groups_vi = JSON.parse(JSON.stringify(template.slide_groups_vi || []));
      }
    } catch {
      toast.add({ title: 'Failed to load template', color: 'error' });
      router.push('/admin/collections');
    }
  }
});

// Sortable.js for slide groups
const slideGroupsContainer = ref<HTMLElement | null>(null);
const slidesRefs: Record<number, HTMLElement | null> = {};
let groupSortable: Sortable | null = null;
const slideSortables: Record<number, Sortable> = {};

function setSlidesRef(idx: number, el: any) {
  slidesRefs[idx] = el as HTMLElement | null;
}

onMounted(() => {
  nextTick(() => initSortables());
});

watch(() => form.slide_groups.length, () => {
  nextTick(() => initSortables());
});

function initSortables() {
  // Group-level sortable
  if (slideGroupsContainer.value) {
    groupSortable?.destroy();
    groupSortable = Sortable.create(slideGroupsContainer.value, {
      handle: '.drag-handle-group',
      animation: 150,
      onEnd(evt) {
        if (evt.oldIndex !== undefined && evt.newIndex !== undefined) {
          const item = form.slide_groups.splice(evt.oldIndex, 1)[0];
          form.slide_groups.splice(evt.newIndex, 0, item);
          updatePositions();
        }
      },
    });
  }

  // Slide-level sortables
  Object.keys(slideSortables).forEach(k => slideSortables[Number(k)]?.destroy());
  form.slide_groups.forEach((_, idx) => {
    const el = slidesRefs[idx];
    if (el) {
      slideSortables[idx] = Sortable.create(el, {
        handle: '.drag-handle-slide',
        animation: 150,
        onEnd(evt) {
          if (evt.oldIndex !== undefined && evt.newIndex !== undefined) {
            const slides = form.slide_groups[idx].slides;
            const item = slides.splice(evt.oldIndex, 1)[0];
            slides.splice(evt.newIndex, 0, item);
          }
        },
      });
    }
  });
}

function updatePositions() {
  form.slide_groups.forEach((g, i) => { g.position = i + 1; });
}

// Group management
function addSlideGroup() {
  const newId = `group-${Date.now()}`;
  form.slide_groups.push({
    id: newId,
    title: '',
    description: '',
    position: form.slide_groups.length + 1,
    slides: [],
  });
  // Also add a matching VI group
  form.slide_groups_vi.push({
    id: newId,
    title: '',
    description: '',
    position: form.slide_groups_vi.length + 1,
    slides: [],
  });
}

function removeSlideGroup(idx: number) {
  form.slide_groups.splice(idx, 1);
  form.slide_groups_vi.splice(idx, 1);
  updatePositions();
}

function toggleCollapse(groupId: string) {
  if (collapsedGroups.value.has(groupId)) {
    collapsedGroups.value.delete(groupId);
  } else {
    collapsedGroups.value.add(groupId);
  }
}

// Vietnamese group helper
function getViGroup(gIdx: number): SlideGroup {
  while (form.slide_groups_vi.length <= gIdx) {
    form.slide_groups_vi.push({ id: '', title: '', description: '', position: gIdx + 1, slides: [] });
  }
  return form.slide_groups_vi[gIdx];
}

// Slide management
function addSlide(gIdx: number) {
  editingGroupIdx.value = gIdx;
  editingSlideIsNew.value = true;
  editingSlide.value = {
    id: `slide-${Date.now()}`,
    type: 'journal_prompt',
    question: '',
    question_vi: '',
    title: '',
    title_vi: '',
    content: '',
    content_vi: '',
    config: { allowAI: true },
  };
  slideModalOpen.value = true;
}

function editSlide(gIdx: number, sIdx: number) {
  editingGroupIdx.value = gIdx;
  editingSlideIdx.value = sIdx;
  editingSlideIsNew.value = false;
  const slide = form.slide_groups[gIdx].slides[sIdx];
  editingSlide.value = JSON.parse(JSON.stringify(slide));
  slideModalOpen.value = true;
}

function removeSlide(gIdx: number, sIdx: number) {
  form.slide_groups[gIdx].slides.splice(sIdx, 1);
}

function saveSlide() {
  const slideData = JSON.parse(JSON.stringify(editingSlide.value)) as SlideData;
  if (editingSlideIsNew.value) {
    form.slide_groups[editingGroupIdx.value].slides.push(slideData);
  } else {
    form.slide_groups[editingGroupIdx.value].slides[editingSlideIdx.value] = slideData;
  }
  slideModalOpen.value = false;
}

function slideTypeColor(type: string): string {
  const colors: Record<string, string> = {
    emotion_log: 'info',
    sleep_check: 'info',
    journal_prompt: 'success',
    doc: 'warning',
    further_reading: 'neutral',
    cta: 'error',
    questionnaire: 'primary',
    completion: 'success',
    date_picker: 'neutral',
    star_rating: 'warning',
    checklist_input: 'info',
  };
  return colors[type] || 'neutral';
}

function slideTypeLabel(type: string): string {
  const labels: Record<string, string> = {
    emotion_log: 'Emotion Log',
    sleep_check: 'Sleep Check',
    journal_prompt: 'Journal Prompt',
    doc: 'Document',
    further_reading: 'Further Reading',
    cta: 'Call to Action',
    date_picker: 'Date Picker',
    star_rating: 'Star Rating',
    checklist_input: 'Checklist',
    questionnaire: 'Questionnaire',
    completion: 'Completion',
  };
  return labels[type] || type;
}

// Save
function validate(): boolean {
  Object.keys(errors).forEach(k => delete errors[k]);
  if (!form.title.trim()) errors.title = 'Title is required';
  if (!form.type) errors.type = 'Type is required';
  if (!form.category) errors.category = 'Category is required';
  if (form.slide_groups.length === 0) errors.slide_groups = 'At least one slide group is required';
  return Object.keys(errors).length === 0;
}

async function handleSave() {
  if (!validate()) {
    toast.add({ title: 'Please fix errors before saving', color: 'error' });
    return;
  }

  saving.value = true;
  try {
    updatePositions();
    const data: CreateUpdateTemplateRequest = {
      title: form.title,
      title_vi: form.title_vi || undefined,
      description: form.description || undefined,
      description_vi: form.description_vi || undefined,
      type: form.type as 'learn' | 'journal',
      category: form.category,
      slide_groups: form.slide_groups,
      slide_groups_vi: form.slide_groups_vi.length > 0 ? form.slide_groups_vi : undefined,
      is_active: form.is_active,
    };

    if (isNew.value) {
      const t = await adminStore.createTemplate(data);
      toast.add({ title: 'Collection created', color: 'success' });
      router.push(`/admin/collections/${t.id}`);
    } else {
      await adminStore.updateTemplate(id.value, data);
      toast.add({ title: 'Collection saved', color: 'success' });
    }
  } catch {
    toast.add({ title: 'Failed to save', color: 'error' });
  } finally {
    saving.value = false;
  }
}
</script>
