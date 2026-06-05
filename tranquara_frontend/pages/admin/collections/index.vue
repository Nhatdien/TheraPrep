<template>
  <div>
    <div class="flex items-center justify-between mb-6">
      <h1 class="text-2xl font-bold">{{ $t('admin.collections.title') }}</h1>
      <UButton icon="i-heroicons-plus" to="/admin/collections/new" color="primary">
        {{ $t('admin.collections.newCollection') }}
      </UButton>
    </div>

    <!-- Filters -->
    <div class="flex flex-wrap gap-3 mb-6">
      <USelect v-model="adminStore.filters.type" :items="typeOptions" :placeholder="$t('admin.collections.filters.allTypes')" class="w-40" size="lg" />
      <USelect v-model="adminStore.filters.category" :items="categoryOptions" :placeholder="$t('admin.collections.filters.allCategories')" class="w-48" size="lg" />
      <USelect v-model="adminStore.filters.status" :items="statusOptions" :placeholder="$t('admin.collections.filters.allStatus')" class="w-40" size="lg" />
      <UInput v-model="adminStore.filters.search" :placeholder="$t('admin.collections.filters.searchPlaceholder')" icon="i-heroicons-magnifying-glass" class="w-60" size="lg" />
    </div>

    <!-- Table -->
    <div class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 overflow-hidden">
      <div v-if="adminStore.isLoading" class="p-8 text-center text-gray-500">
        {{ $t('common.loading') }}
      </div>
      <table v-else class="w-full text-sm">
        <thead class="bg-gray-50 dark:bg-gray-800/50">
          <tr>
            <th class="text-left px-4 py-3 font-medium">{{ $t('admin.collections.table.title') }}</th>
            <th class="text-left px-4 py-3 font-medium">{{ $t('admin.collections.table.type') }}</th>
            <th class="text-left px-4 py-3 font-medium">{{ $t('admin.collections.table.category') }}</th>
            <th class="text-center px-4 py-3 font-medium">{{ $t('admin.collections.table.status') }}</th>
            <th class="text-center px-4 py-3 font-medium">{{ $t('admin.collections.table.slides') }}</th>
            <th class="text-right px-4 py-3 font-medium">{{ $t('admin.collections.table.actions') }}</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-100 dark:divide-gray-800">
          <tr v-for="template in adminStore.filteredTemplates" :key="template.id" class="hover:bg-gray-50 dark:hover:bg-gray-800/30">
            <td class="px-4 py-3">
              <p class="font-medium">{{ template.title }}</p>
              <p v-if="template.description" class="text-xs text-gray-500 truncate max-w-xs">{{ template.description }}</p>
            </td>
            <td class="px-4 py-3">
              <UBadge :color="template.type === 'learn' ? 'info' : 'warning'" variant="subtle" size="md" class="min-w-[70px] justify-center">
                {{ template.type }}
              </UBadge>
            </td>
            <td class="px-4 py-3">
              <UBadge color="neutral" variant="subtle" size="md">
                {{ formatCategory(template.category) }}
              </UBadge>
            </td>
            <td class="px-4 py-3 text-center">
              <UBadge :color="template.is_active ? 'success' : 'neutral'" variant="subtle" size="md">
                {{ template.is_active ? $t('admin.collections.table.active') : $t('admin.collections.table.inactive') }}
              </UBadge>
            </td>
            <td class="px-4 py-3 text-center text-gray-500">
              {{ countSlides(template) }}
            </td>
            <td class="px-4 py-3 text-right">
              <UDropdownMenu :items="getRowActions(template)">
                <UButton icon="i-heroicons-ellipsis-vertical" variant="ghost" size="sm" />
              </UDropdownMenu>
            </td>
          </tr>
          <tr v-if="adminStore.filteredTemplates.length === 0">
            <td colspan="6" class="px-4 py-8 text-center text-gray-500">
              {{ $t('admin.collections.table.noCollections') }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Delete Confirmation Modal -->
    <UModal v-model:open="deleteModalOpen">
      <template #content>
        <div class="p-6">
          <h3 class="text-lg font-semibold mb-2">{{ $t('admin.collections.deleteModal.title') }}</h3>
          <p class="text-sm text-gray-600 dark:text-gray-400 mb-4">
            {{ $t('admin.collections.deleteModal.confirm', { title: deleteTarget?.title }) }}
          </p>
          <div class="flex justify-end gap-2">
            <UButton variant="outline" @click="deleteModalOpen = false">{{ $t('admin.collections.deleteModal.cancel') }}</UButton>
            <UButton color="error" @click="confirmDelete">{{ $t('admin.collections.deleteModal.delete') }}</UButton>
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
const { t } = useI18n();

const deleteModalOpen = ref(false);
const deleteTarget = ref<AdminJournalTemplate | null>(null);

onMounted(() => {
  adminStore.loadTemplates();
});

const typeOptions = computed(() => [
  { label: t('admin.collections.filters.allTypes'), value: '__all__' },
  { label: 'Learn', value: 'learn' },
  { label: 'Journal', value: 'journal' },
]);

const statusOptions = computed(() => [
  { label: t('admin.collections.filters.allStatus'), value: '__all__' },
  { label: t('admin.collections.table.active'), value: 'active' },
  { label: t('admin.collections.table.inactive'), value: 'inactive' },
]);

const categoryOptions = computed(() => [
  { label: t('admin.collections.filters.allCategories'), value: '__all__' },
  ...adminStore.categories.map(c => ({ label: formatCategory(c), value: c })),
]);

function countSlides(template: AdminJournalTemplate): number {
  return template.slide_groups?.reduce((acc, g) => acc + (g.slides?.length || 0), 0) || 0;
}

function formatCategory(cat: string): string {
  return cat.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
}

function getRowActions(template: AdminJournalTemplate) {
  return [
    [
      { label: t('admin.collections.rowActions.edit'), icon: 'i-heroicons-pencil-square', onSelect: () => router.push(`/admin/collections/${template.id}`) },
      { label: t('admin.collections.rowActions.preview'), icon: 'i-heroicons-eye', onSelect: () => router.push(`/admin/collections/preview/${template.id}`) },
      { label: t('admin.collections.rowActions.duplicate'), icon: 'i-heroicons-document-duplicate', onSelect: () => handleDuplicate(template.id) },
      { label: template.is_active ? t('admin.collections.rowActions.deactivate') : t('admin.collections.rowActions.activate'), icon: 'i-heroicons-arrow-path', onSelect: () => handleToggle(template.id) },
    ],
    [
      { label: t('admin.collections.rowActions.delete'), icon: 'i-heroicons-trash', color: 'error' as const, onSelect: () => { deleteTarget.value = template; deleteModalOpen.value = true; } },
    ],
  ];
}

async function handleDuplicate(id: string) {
  try {
    const tmpl = await adminStore.duplicateTemplate(id);
    toast.add({ title: t('admin.collections.toast.duplicated', { title: tmpl.title }), color: 'success' });
  } catch {
    toast.add({ title: t('admin.collections.toast.duplicateFailed'), color: 'error' });
  }
}

async function handleToggle(id: string) {
  try {
    const tmpl = await adminStore.toggleActive(id);
    toast.add({ title: t('admin.collections.toast.toggled', { status: tmpl.is_active ? t('admin.collections.table.active') : t('admin.collections.table.inactive') }), color: 'success' });
  } catch {
    toast.add({ title: t('admin.collections.toast.toggleFailed'), color: 'error' });
  }
}

async function confirmDelete() {
  if (!deleteTarget.value) return;
  try {
    await adminStore.deleteTemplate(deleteTarget.value.id);
    toast.add({ title: t('admin.collections.toast.deleted'), color: 'success' });
  } catch {
    toast.add({ title: t('admin.collections.toast.deleteFailed'), color: 'error' });
  }
  deleteModalOpen.value = false;
  deleteTarget.value = null;
}
</script>
