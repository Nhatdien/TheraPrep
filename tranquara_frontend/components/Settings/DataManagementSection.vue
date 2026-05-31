<template>
  <div class="space-y-4">
    <h2 class="text-sm font-semibold text-muted uppercase tracking-wider px-1">{{ $t('settings.dataManagement.heading') }}</h2>

    <UCard>
      <div class="divide-y divide-default">
        <!-- Export Data -->
        <UButton
          :padded="false"
          color="neutral"
          variant="ghost"
          block
          class="justify-start"
          :loading="exporting"
          @click="handleExportData"
        >
          <div class="py-4 flex items-center justify-between w-full">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 bg-muted rounded-lg flex items-center justify-center">
                <Download class="w-5 h-5 text-muted" />
              </div>
              <div class="text-left">
                <p class="text-sm font-medium text-default">{{ $t('settings.dataManagement.exportData') }}</p>
                <p class="text-xs text-muted">{{ $t('settings.dataManagement.exportDataDesc') }}</p>
              </div>
            </div>
            <ChevronRight class="w-5 h-5 text-muted" />
          </div>
        </UButton>

        <!-- Import Data -->
        <UButton
          :padded="false"
          color="neutral"
          variant="ghost"
          block
          class="justify-start"
          @click="triggerImportFile"
        >
          <div class="py-4 flex items-center justify-between w-full">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 bg-muted rounded-lg flex items-center justify-center">
                <Upload class="w-5 h-5 text-muted" />
              </div>
              <div class="text-left">
                <p class="text-sm font-medium text-default">{{ $t('settings.dataManagement.importData') }}</p>
                <p class="text-xs text-muted">{{ $t('settings.dataManagement.importDataDesc') }}</p>
              </div>
            </div>
            <ChevronRight class="w-5 h-5 text-muted" />
          </div>
        </UButton>
        <input
          ref="fileInput"
          type="file"
          accept=".json"
          class="hidden"
          @change="handleImportFile"
        />

        <!-- Delete Account -->
        <UButton
          :padded="false"
          color="neutral"
          variant="ghost"
          block
          class="justify-start"
          @click="showDeleteModal = true"
        >
          <div class="py-4 flex items-center justify-between w-full">
            <div class="flex items-center gap-3">
              <div class="w-10 h-10 bg-error/10 rounded-lg flex items-center justify-center">
                <Trash2 class="w-5 h-5 text-error" />
              </div>
              <div class="text-left">
                <p class="text-sm font-medium text-error">{{ $t('settings.dataManagement.deleteAccount') }}</p>
                <p class="text-xs text-muted">{{ $t('settings.dataManagement.deleteAccountDesc') }}</p>
              </div>
            </div>
            <ChevronRight class="w-5 h-5 text-muted" />
          </div>
        </UButton>
      </div>
    </UCard>

    <!-- Delete Account Modal -->
    <UModal v-model:open="showDeleteModal">
      <template #header>
        <div class="flex items-center gap-2">
          <AlertTriangle class="w-5 h-5 text-error" />
          <span class="font-semibold text-highlighted">{{ $t('settings.dataManagement.deleteAccount') }}</span>
        </div>
      </template>

      <template #body>
        <div class="space-y-4">
          <!-- Step 1: Warning -->
          <div v-if="deleteStep === 1" class="space-y-4">
            <p class="text-sm text-muted">
              {{ $t('settings.dataManagement.deleteWarning') }}
            </p>
            <ul class="text-sm text-muted space-y-1 ml-4">
              <li class="flex items-center gap-2">
                <span class="w-1.5 h-1.5 bg-error rounded-full" />
                {{ $t('settings.dataManagement.deleteItems.journals') }}
              </li>
              <li class="flex items-center gap-2">
                <span class="w-1.5 h-1.5 bg-error rounded-full" />
                {{ $t('settings.dataManagement.deleteItems.learning') }}
              </li>
              <li class="flex items-center gap-2">
                <span class="w-1.5 h-1.5 bg-error rounded-full" />
                {{ $t('settings.dataManagement.deleteItems.aiMemory') }}
              </li>
              <li class="flex items-center gap-2">
                <span class="w-1.5 h-1.5 bg-error rounded-full" />
                {{ $t('settings.dataManagement.deleteItems.accountSettings') }}
              </li>
            </ul>
            <UAlert
              color="warning"
              icon="i-lucide-download"
              :title="$t('settings.dataManagement.downloadFirst')"
              :description="$t('settings.dataManagement.downloadFirstDesc')"
            />
          </div>

          <!-- Step 2: Confirm with username -->
          <div v-if="deleteStep === 2" class="space-y-4">
            <p class="text-sm text-muted">
              {{ $t('settings.dataManagement.confirmDeletePrompt', { username }) }}
            </p>
            <UInput
              v-model="confirmUsername"
              :placeholder="$t('settings.dataManagement.enterUsername')"
              :color="confirmError ? 'error' : undefined"
            />
            <p v-if="confirmError" class="text-xs text-error">
              {{ $t('settings.dataManagement.usernameNoMatch') }}
            </p>
          </div>
        </div>
      </template>

      <template #footer>
        <div class="flex gap-3 justify-end w-full">
          <UButton
            color="neutral"
            variant="ghost"
            @click="cancelDelete"
          >
            {{ $t('common.cancel') }}
          </UButton>

          <template v-if="deleteStep === 1">
            <UButton
              color="neutral"
              variant="outline"
              @click="handleExportData"
            >
              <template #leading>
                <Download class="w-4 h-4" />
              </template>
              {{ $t('settings.dataManagement.exportFirst') }}
            </UButton>
            <UButton
              color="error"
              @click="deleteStep = 2"
            >
              {{ $t('settings.dataManagement.continue') }}
            </UButton>
          </template>

          <template v-if="deleteStep === 2">
            <UButton
              color="error"
              :loading="deleting"
              :disabled="!confirmUsername"
              @click="confirmDelete"
            >
              {{ $t('settings.dataManagement.deleteAccount') }}
            </UButton>
          </template>
        </div>
      </template>
    </UModal>
  </div>
</template>

<script setup lang="ts">
import { Download, Upload, Trash2, ChevronRight, AlertTriangle } from 'lucide-vue-next';
import { useAuthStore } from '~/stores/stores/auth_store';
import { useSettingsStore } from '~/stores/stores/settings_store';
import TranquaraSDK from '~/stores/tranquara_sdk';
import type { ExportFile } from '~/stores/data_portability';

const authStore = useAuthStore();
const settingsStore = useSettingsStore();
const toast = useToast();
const { t } = useI18n();

const username = computed(() => authStore.user?.preferred_username || '');

// ─── Export ─────────────────────────────────────────────────────────────────

const exporting = ref(false);

const handleExportData = async () => {
  exporting.value = true;
  try {
    const sdk = await TranquaraSDK.getInstance();
    const data = await sdk.exportData();

    // Create downloadable JSON file
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `tranquara_export_${new Date().toISOString().slice(0, 10)}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    toast.add({
      title: t('settings.dataManagement.exportSuccess'),
      description: t('settings.dataManagement.exportSuccessDesc', { count: data.counts.journals + data.counts.emotion_logs }),
      icon: 'i-lucide-check',
      color: 'success',
    });
  } catch (error) {
    console.error('Export failed:', error);
    toast.add({
      title: t('settings.dataManagement.exportFailed'),
      description: t('settings.dataManagement.exportFailedDesc'),
      icon: 'i-lucide-alert-circle',
      color: 'error',
    });
  } finally {
    exporting.value = false;
  }
};

// ─── Import ─────────────────────────────────────────────────────────────────

const fileInput = ref<HTMLInputElement | null>(null);

const triggerImportFile = () => {
  fileInput.value?.click();
};

const handleImportFile = async (event: Event) => {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (!file) return;

  try {
    const text = await file.text();
    const importData: ExportFile = JSON.parse(text);

    // Basic client-side validation
    if (importData.app !== 'tranquara') {
      toast.add({
        title: t('settings.dataManagement.importInvalidFile'),
        description: t('settings.dataManagement.importInvalidFileDesc'),
        icon: 'i-lucide-alert-circle',
        color: 'error',
      });
      return;
    }

    const sdk = await TranquaraSDK.getInstance();
    const result = await sdk.importData(importData);

    const totalImported = result.result.imported.journals + result.result.imported.emotion_logs +
      result.result.imported.learned_slide_groups + result.result.imported.therapy_sessions;

    toast.add({
      title: t('settings.dataManagement.importSuccess'),
      description: t('settings.dataManagement.importSuccessDesc', { count: totalImported }),
      icon: 'i-lucide-check',
      color: 'success',
    });
  } catch (error) {
    console.error('Import failed:', error);
    toast.add({
      title: t('settings.dataManagement.importFailed'),
      description: t('settings.dataManagement.importFailedDesc'),
      icon: 'i-lucide-alert-circle',
      color: 'error',
    });
  } finally {
    // Reset file input so same file can be re-imported
    if (target) target.value = '';
  }
};

// ─── Delete Account ─────────────────────────────────────────────────────────

const showDeleteModal = ref(false);
const deleteStep = ref(1);
const confirmUsername = ref('');
const confirmError = ref(false);
const deleting = ref(false);

const cancelDelete = () => {
  showDeleteModal.value = false;
  deleteStep.value = 1;
  confirmUsername.value = '';
  confirmError.value = false;
};

const confirmDelete = async () => {
  if (confirmUsername.value !== username.value) {
    confirmError.value = true;
    return;
  }

  confirmError.value = false;
  deleting.value = true;

  try {
    // Clear all local settings data
    await settingsStore.clearLocalData();

    // TODO: Call backend DELETE /api/account when ready

    // Log out the user
    await authStore.logout();

    toast.add({
      title: t('settings.dataManagement.accountDeleted'),
      description: t('settings.dataManagement.accountDeletedDesc'),
      icon: 'i-lucide-check',
      color: 'success',
    });
  } catch (error) {
    console.error('Failed to delete account:', error);
    toast.add({
      title: t('settings.dataManagement.deletionFailed'),
      description: t('settings.dataManagement.deletionFailedDesc'),
      icon: 'i-lucide-alert-circle',
      color: 'error',
    });
  } finally {
    deleting.value = false;
    cancelDelete();
  }
};

// Reset confirm error when user types
watch(confirmUsername, () => {
  confirmError.value = false;
});
</script>
