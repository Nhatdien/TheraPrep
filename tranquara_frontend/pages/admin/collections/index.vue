<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold">Collections</h1>
      <UButton icon="i-heroicons-plus" to="/admin/collections/new" color="primary">
        New Collection
      </UButton>
    </div>

    <!-- Filters -->
    <div class="flex flex-wrap gap-3 mb-6">
      <USelect v-model="adminStore.filters.type" :items="typeOptions" placeholder="All Types" class="w-40" size="lg" />
      <USelect v-model="adminStore.filters.category" :items="categoryOptions" placeholder="All Categories" class="w-48" size="lg" />
      <USelect v-model="adminStore.filters.status" :items="statusOptions" placeholder="All Status" class="w-40" size="lg" />
      <UInput v-model="adminStore.filters.search" placeholder="Search title..." icon="i-heroicons-magnifying-glass" class="w-60" size="lg" />
    </div>

    <!-- Table -->
    <div class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 overflow-hidden">
      <div v-if="adminStore.isLoading" class="p-8 text-center text-gray-500">
        Loading...
      </div>
      <table v-else class="w-full text-sm">
        <thead class="bg-gray-50 dark:bg-gray-800/50">
          <tr>
            <th class="text-left px-4 py-3 font-medium">Title</th>
            <th class="text-left px-4 py-3 font-medium">Type</th>
            <th class="text-left px-4 py-3 font-medium">Category</th>
            <th class="text-center px-4 py-3 font-medium">Status</th>
            <th class="text-center px-4 py-3 font-medium">Slides</th>
            <th class="text-right px-4 py-3 font-medium">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100 dark:divide-gray-800">
          <tr v-for="t in adminStore.filteredTemplates" :key="t.id" class="hover:bg-gray-50 dark:hover:bg-gray-800/30">
            <td class="px-4 py-3">
              <p class="font-medium">{{ t.title }}</p>
              <p v-if="t.description" class="text-xs text-gray-500 truncate max-w-xs">{{ t.description }}</p>
            </td>
            <td class="px-4 py-3">
              <UBadge :color="t.type === 'learn' ? 'info' : 'warning'" variant="subtle" size="md" class="min-w-[70px] justify-center">
                {{ t.type }}
              </UBadge>
            </td>
            <td class="px-4 py-3">
              <UBadge color="neutral" variant="subtle" size="md">
                {{ formatCategory(t.category) }}
              </UBadge>
            </td>
            <td class="px-4 py-3 text-center">
              <UBadge :color="t.is_active ? 'success' : 'neutral'" variant="subtle" size="md">
                {{ t.is_active ? 'Active' : 'Inactive' }}
              </UBadge>
            </td>
            <td class="px-4 py-3 text-center text-gray-500">
              {{ countSlides(t) }}
            </td>
            <td class="px-4 py-3 text-right">
              <UDropdownMenu :items="getRowActions(t)">
                <UButton icon="i-heroicons-ellipsis-vertical" variant="ghost" size="sm" />
              </UDropdownMenu>
            </td>
          </tr>
          <tr v-if="adminStore.filteredTemplates.length === 0">
            <td colspan="6" class="px-4 py-8 text-center text-gray-500">
              No collections found
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Delete Confirmation Modal -->
    <UModal v-model:open="deleteModalOpen">
      <template #content>
        <div class="p-6">
          <h3 class="text-lg font-semibold mb-2">Delete Collection</h3>
          <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
            Are you sure you want to delete "<strong>{{ deleteTarget?.title }}</strong>"? This cannot be undone.
          </p>
          <div class="flex justify-end gap-2">
            <UButton variant="outline" @click="deleteModalOpen = false">Cancel</UButton>
            <UButton color="error" @click="confirmDelete">Delete</UButton>
          </div>
        </div>
      </template>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import { useAdminStore } from '~/stores/stores/admin_store';
import type { AdminJournalTemplate } from '~/stores/admin_templates';

definePageMeta({
  layout: 'admin' as any,
  middleware: ['admin' as any],
});

const adminStore = useAdminStore();
const toast = useToast();
const router = useRouter();

const deleteModalOpen = ref(false);
const deleteTarget = ref<AdminJournalTemplate | null>(null);

onMounted(() => {
  adminStore.loadTemplates();
});

const typeOptions = [
  { label: 'All Types', value: '' },
  { label: 'Learn', value: 'learn' },
  { label: 'Journal', value: 'journal' },
];

const statusOptions = [
  { label: 'All Status', value: '' },
  { label: 'Active', value: 'active' },
  { label: 'Inactive', value: 'inactive' },
];

const categoryOptions = computed(() => [
  { label: 'All Categories', value: '' },
  ...adminStore.categories.map(c => ({ label: c, value: c })),
]);

function countSlides(t: AdminJournalTemplate): number {
  return t.slide_groups?.reduce((acc, g) => acc + (g.slides?.length || 0), 0) || 0;
}

function formatCategory(cat: string): string {
  return cat.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
}

function getRowActions(t: AdminJournalTemplate) {
  return [
    [
      { label: 'Edit', icon: 'i-heroicons-pencil-square', onSelect: () => router.push(`/admin/collections/${t.id}`) },
      { label: 'Preview', icon: 'i-heroicons-eye', onSelect: () => router.push(`/admin/collections/preview/${t.id}`) },
      { label: 'Duplicate', icon: 'i-heroicons-document-duplicate', onSelect: () => handleDuplicate(t.id) },
      { label: t.is_active ? 'Deactivate' : 'Activate', icon: 'i-heroicons-arrow-path', onSelect: () => handleToggle(t.id) },
    ],
    [
      { label: 'Delete', icon: 'i-heroicons-trash', color: 'error' as const, onSelect: () => { deleteTarget.value = t; deleteModalOpen.value = true; } },
    ],
  ];
}

async function handleDuplicate(id: string) {
  try {
    const t = await adminStore.duplicateTemplate(id);
    toast.add({ title: `Duplicated as "${t.title}"`, color: 'success' });
  } catch {
    toast.add({ title: 'Duplicate failed', color: 'error' });
  }
}

async function handleToggle(id: string) {
  try {
    const t = await adminStore.toggleActive(id);
    toast.add({ title: `Collection is now ${t.is_active ? 'active' : 'inactive'}`, color: 'success' });
  } catch {
    toast.add({ title: 'Toggle failed', color: 'error' });
  }
}

async function confirmDelete() {
  if (!deleteTarget.value) return;
  try {
    await adminStore.deleteTemplate(deleteTarget.value.id);
    toast.add({ title: 'Collection deleted', color: 'success' });
  } catch {
    toast.add({ title: 'Delete failed', color: 'error' });
  }
  deleteModalOpen.value = false;
  deleteTarget.value = null;
}
</script>
