<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">Dashboard</h1>

    <!-- Stats Cards -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
      <div v-for="stat in statsCards" :key="stat.label" class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4">
        <p class="text-2xl font-bold" :class="stat.color">{{ stat.value }}</p>
        <p class="text-xs text-gray-500 mt-1">{{ stat.label }}</p>
      </div>
    </div>

    <!-- Quick Actions + Category Breakdown -->
    <div class="grid lg:grid-cols-2 gap-6">
      <!-- Category Breakdown -->
      <div class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-5">
        <h2 class="font-semibold text-sm mb-3">By Category</h2>
        <div class="space-y-2">
          <div v-for="cat in categoryBreakdown" :key="cat.name" class="flex justify-between text-sm">
            <span class="text-gray-600 dark:text-gray-400">{{ cat.name }}</span>
            <span class="font-medium">{{ cat.count }}</span>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-5">
        <h2 class="font-semibold text-sm mb-3">Quick Actions</h2>
        <div class="space-y-3">
          <UButton block icon="i-heroicons-plus" to="/admin/collections/new" color="primary">
            New Collection
          </UButton>
          <UButton block icon="i-heroicons-arrow-down-tray" to="/admin/import-export" variant="outline">
            Import JSON
          </UButton>
          <UButton block icon="i-heroicons-arrow-up-tray" variant="outline" @click="handleExport">
            Export All
          </UButton>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useAdminStore } from '~/stores/stores/admin_store';

definePageMeta({
  layout: 'admin' as any,
  middleware: ['admin' as any],
});

const adminStore = useAdminStore();
const toast = useToast();

onMounted(() => {
  if (adminStore.templates.length === 0) {
    adminStore.loadTemplates();
  }
});

const statsCards = computed(() => {
  const s = adminStore.stats;
  return [
    { label: 'Total Collections', value: s.total, color: 'text-gray-900 dark:text-white' },
    { label: 'Active', value: s.active, color: 'text-green-600' },
    { label: 'Inactive', value: s.inactive, color: 'text-gray-400' },
    { label: 'Learn Type', value: s.learn, color: 'text-blue-600' },
  ];
});

const categoryBreakdown = computed(() => {
  const counts: Record<string, number> = {};
  adminStore.templates.forEach(t => {
    counts[t.category] = (counts[t.category] || 0) + 1;
  });
  return Object.entries(counts)
    .map(([name, count]) => ({ name, count }))
    .sort((a, b) => b.count - a.count);
});

async function handleExport() {
  try {
    const res = await adminStore.exportTemplates();
    const blob = new Blob([JSON.stringify(res.templates, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `collections-export-${new Date().toISOString().slice(0, 10)}.json`;
    a.click();
    URL.revokeObjectURL(url);
    toast.add({ title: 'Export complete', color: 'success' });
  } catch {
    toast.add({ title: 'Export failed', color: 'error' });
  }
}
</script>
