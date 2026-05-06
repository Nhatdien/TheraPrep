<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">Import / Export</h1>

    <div class="grid lg:grid-cols-2 gap-6">
      <!-- Export -->
      <div class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-5">
        <h2 class="font-semibold text-sm mb-3">Export Collections</h2>
        <p class="text-xs text-gray-500 mb-4">Download all collections as a JSON file for backup or transfer.</p>
        <div class="space-y-2">
          <UButton block icon="i-heroicons-arrow-up-tray" @click="handleExport('all')">Export All</UButton>
          <UButton block icon="i-heroicons-arrow-up-tray" variant="outline" @click="handleExport('active')">Export Active Only</UButton>
        </div>
      </div>

      <!-- Import -->
      <div class="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-5">
        <h2 class="font-semibold text-sm mb-3">Import Collections</h2>

        <!-- File Drop -->
        <div
          v-if="!importPreview"
          class="border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-lg p-8 text-center cursor-pointer hover:border-primary-400 transition-colors"
          @click="fileInputRef?.click()"
          @dragover.prevent
          @drop.prevent="handleDrop"
        >
          <UIcon name="i-heroicons-document-arrow-up" class="w-8 h-8 text-gray-400 mx-auto mb-2" />
          <p class="text-sm text-gray-500">Drop JSON file here or click to browse</p>
          <input ref="fileInputRef" type="file" accept=".json" class="hidden" @change="handleFileSelect" />
        </div>

        <!-- Import Preview -->
        <div v-else class="space-y-3">
          <div class="flex items-center gap-2 text-sm">
            <UIcon name="i-heroicons-check-circle" class="w-4 h-4 text-green-500" />
            <span>{{ importPreview.length }} collections found</span>
          </div>

          <div class="max-h-40 overflow-y-auto space-y-1 border border-gray-100 dark:border-gray-700 rounded p-2">
            <div v-for="(t, i) in importPreview" :key="i" class="text-xs flex items-center gap-2">
              <UBadge :color="t.type === 'learn' ? 'info' : 'warning'" variant="subtle" size="xs">{{ t.type }}</UBadge>
              <span class="truncate">{{ t.title }}</span>
            </div>
          </div>

          <UFormField label="Conflict Strategy">
            <USelect v-model="importStrategy" :items="strategyOptions" size="sm" />
          </UFormField>

          <div class="flex gap-2">
            <UButton variant="outline" @click="importPreview = null">Cancel</UButton>
            <UButton color="primary" :loading="importing" @click="confirmImport">Confirm Import</UButton>
          </div>
        </div>

        <!-- Import Result -->
        <div v-if="importResult" class="mt-4 p-3 bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded text-sm">
          <p class="font-medium text-green-700 dark:text-green-400">Import Complete</p>
          <p class="text-xs text-green-600 dark:text-green-500 mt-1">
            Created: {{ importResult.created }} | Skipped: {{ importResult.skipped }}
            <span v-if="importResult.errors?.length"> | Errors: {{ importResult.errors.length }}</span>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useAdminStore } from '~/stores/stores/admin_store';
import type { CreateUpdateTemplateRequest, ImportTemplatesResponse } from '~/stores/admin_templates';

definePageMeta({
  layout: 'admin' as any,
  middleware: ['admin' as any],
});

const adminStore = useAdminStore();
const toast = useToast();

const fileInputRef = ref<HTMLInputElement | null>(null);
const importPreview = ref<CreateUpdateTemplateRequest[] | null>(null);
const importStrategy = ref('new_ids');
const importing = ref(false);
const importResult = ref<ImportTemplatesResponse | null>(null);

const strategyOptions = [
  { label: 'Generate new IDs', value: 'new_ids' },
  { label: 'Skip duplicates', value: 'skip' },
  { label: 'Overwrite existing', value: 'overwrite' },
];

async function handleExport(scope: 'all' | 'active') {
  try {
    const res = await adminStore.exportTemplates();
    let data = res.templates;
    if (scope === 'active') {
      data = data.filter(t => t.is_active);
    }
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `collections-${scope}-${new Date().toISOString().slice(0, 10)}.json`;
    a.click();
    URL.revokeObjectURL(url);
    toast.add({ title: 'Export complete', color: 'success' });
  } catch {
    toast.add({ title: 'Export failed', color: 'error' });
  }
}

function handleFileSelect(event: Event) {
  const file = (event.target as HTMLInputElement).files?.[0];
  if (file) parseFile(file);
}

function handleDrop(event: DragEvent) {
  const file = event.dataTransfer?.files?.[0];
  if (file) parseFile(file);
}

function parseFile(file: File) {
  importResult.value = null;
  const reader = new FileReader();
  reader.onload = (e) => {
    try {
      const content = JSON.parse(e.target?.result as string);
      const templates = Array.isArray(content) ? content : content.templates;
      if (!Array.isArray(templates) || templates.length === 0) {
        toast.add({ title: 'Invalid JSON: expected array of templates', color: 'error' });
        return;
      }
      importPreview.value = templates;
    } catch {
      toast.add({ title: 'Invalid JSON file', color: 'error' });
    }
  };
  reader.readAsText(file);
}

async function confirmImport() {
  if (!importPreview.value) return;
  importing.value = true;
  try {
    const res = await adminStore.importTemplates({
      templates: importPreview.value,
      strategy: importStrategy.value as 'skip' | 'overwrite' | 'new_ids',
    });
    importResult.value = res;
    importPreview.value = null;
    toast.add({ title: `Imported ${res.created} collections`, color: 'success' });
  } catch {
    toast.add({ title: 'Import failed', color: 'error' });
  } finally {
    importing.value = false;
  }
}
</script>
