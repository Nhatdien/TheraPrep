<template>
  <UModal
    v-model:open="internalOpen"
    :prevent-close="true"
  >
    <template #content>
      <div class="p-6 text-center space-y-5 max-w-md mx-auto">
        <!-- Icon -->
        <div class="text-4xl">💜</div>

        <!-- Title -->
        <h2 class="text-xl font-bold text-foreground">
          {{ $t('crisis.title') }}
        </h2>

        <!-- Message -->
        <p class="text-sm text-muted leading-relaxed">
          {{ $t('crisis.message') }}
        </p>

        <!-- Hotline cards -->
        <div class="space-y-3 text-left">
          <!-- Vietnam Hotlines (show for all, primary for vi locale) -->
          <template v-if="locale === 'vi'">
            <!-- Ngày Mai Hotline -->
            <div
              class="p-4 rounded-lg border-2 border-amber-200 bg-amber-50 dark:border-amber-800 dark:bg-amber-950"
            >
              <div class="flex items-center justify-between gap-3">
                <div class="min-w-0">
                  <div class="font-semibold text-amber-800 dark:text-amber-300 text-sm">
                    {{ $t('crisis.hotlineNgayMai') }}
                  </div>
                  <div class="text-2xl font-bold text-amber-600 dark:text-amber-400 mt-1">
                    {{ $t('crisis.hotlineNgayMaiNumber') }}
                  </div>
                  <div class="text-xs text-muted mt-1">
                    {{ $t('crisis.hotlineNgayMaiDesc') }}
                  </div>
                </div>
                <div class="flex flex-col gap-2 shrink-0">
                  <UButton
                    color="primary"
                    size="md"
                    icon="i-lucide-phone"
                    @click="callNumber('0963061414')"
                  >
                    {{ $t('crisis.callHotline') }}
                  </UButton>
                  <UButton
                    variant="ghost"
                    size="xs"
                    icon="i-lucide-copy"
                    @click="copyNumber('0963061414')"
                  >
                    {{ copiedNumber === '0963061414' ? $t('crisis.copied') : $t('crisis.copyNumber') }}
                  </UButton>
                </div>
              </div>
            </div>

            <!-- 111 Hotline -->
            <div
              class="p-4 rounded-lg border-2 border-amber-200 bg-amber-50 dark:border-amber-800 dark:bg-amber-950/50"
            >
              <div class="flex items-center justify-between gap-3">
                <div class="min-w-0">
                  <div class="font-semibold text-amber-800 dark:text-amber-300 text-sm">
                    {{ $t('crisis.hotline111') }}
                  </div>
                  <div class="text-2xl font-bold text-amber-600 dark:text-amber-400 mt-1">
                    {{ $t('crisis.hotline111Number') }}
                  </div>
                  <div class="text-xs text-muted mt-1">
                    {{ $t('crisis.hotline111Desc') }}
                  </div>
                </div>
                <div class="flex flex-col gap-2 shrink-0">
                  <UButton
                    color="primary"
                    size="md"
                    icon="i-lucide-phone"
                    @click="callNumber('111')"
                  >
                    {{ $t('crisis.callHotline') }}
                  </UButton>
                  <UButton
                    variant="ghost"
                    size="xs"
                    icon="i-lucide-copy"
                    @click="copyNumber('111')"
                  >
                    {{ copiedNumber === '111' ? $t('crisis.copied') : $t('crisis.copyNumber') }}
                  </UButton>
                </div>
              </div>
            </div>
          </template>

          <!-- English locale: 988 + VN hotlines -->
          <template v-else>
            <!-- 988 Suicide & Crisis Lifeline -->
            <div
              class="p-4 rounded-lg border-2 border-amber-200 bg-amber-50 dark:border-amber-800 dark:bg-amber-950"
            >
              <div class="flex items-center justify-between gap-3">
                <div class="min-w-0">
                  <div class="font-semibold text-amber-800 dark:text-amber-300 text-sm">
                    {{ $t('crisis.hotline988') }}
                  </div>
                  <div class="text-2xl font-bold text-amber-600 dark:text-amber-400 mt-1">
                    {{ $t('crisis.hotline988Number') }}
                  </div>
                  <div class="text-xs text-muted mt-1">
                    {{ $t('crisis.hotline988Desc') }}
                  </div>
                </div>
                <div class="flex flex-col gap-2 shrink-0">
                  <UButton
                    color="primary"
                    size="md"
                    icon="i-lucide-phone"
                    @click="callNumber('988')"
                  >
                    {{ $t('crisis.callHotline') }}
                  </UButton>
                  <UButton
                    variant="ghost"
                    size="xs"
                    icon="i-lucide-copy"
                    @click="copyNumber('988')"
                  >
                    {{ copiedNumber === '988' ? $t('crisis.copied') : $t('crisis.copyNumber') }}
                  </UButton>
                </div>
              </div>
            </div>

            <!-- Vietnam hotlines for English users in Vietnam -->
            <div
              class="p-4 rounded-lg border border-default bg-elevated"
            >
              <div class="text-xs text-muted mb-2">{{ $t('crisis.vietnamHotlines') }}</div>
              <div class="space-y-2">
                <div class="flex items-center justify-between">
                  <div>
                    <span class="text-sm font-medium">{{ $t('crisis.hotlineNgayMai') }}</span>
                    <span class="ml-2 text-amber-600 dark:text-amber-400 font-bold">{{ $t('crisis.hotlineNgayMaiNumber') }}</span>
                  </div>
                  <UButton variant="ghost" size="xs" icon="i-lucide-copy" @click="copyNumber('0963061414')">
                    {{ copiedNumber === '0963061414' ? $t('crisis.copied') : $t('crisis.copyNumber') }}
                  </UButton>
                </div>
                <div class="flex items-center justify-between">
                  <div>
                    <span class="text-sm font-medium">{{ $t('crisis.hotline111') }}</span>
                    <span class="ml-2 text-amber-600 dark:text-amber-400 font-bold">{{ $t('crisis.hotline111Number') }}</span>
                  </div>
                  <UButton variant="ghost" size="xs" icon="i-lucide-copy" @click="copyNumber('111')">
                    {{ copiedNumber === '111' ? $t('crisis.copied') : $t('crisis.copyNumber') }}
                  </UButton>
                </div>
              </div>
            </div>
          </template>
        </div>

        <!-- International Support Link -->
        <div class="pt-2 border-t border-default">
          <a
            href="https://findahelpline.com"
            target="_blank"
            rel="noopener noreferrer"
            class="inline-flex items-center gap-1.5 text-sm text-primary hover:underline"
          >
            <Icon name="i-lucide-globe" class="w-4 h-4" />
            {{ $t('crisis.internationalLink') }}
            <Icon name="i-lucide-external-link" class="w-3 h-3" />
          </a>
        </div>

        <!-- Continue writing button -->
        <button
          class="w-full py-3 px-4 rounded-lg text-sm text-muted border border-default hover:bg-elevated transition-colors"
          @click="handleContinue"
        >
          {{ $t('crisis.continueWriting') }}
        </button>
      </div>
    </template>
  </UModal>
</template>

<script setup lang="ts">
const props = defineProps<{
  modelValue: boolean;
}>();

const emit = defineEmits<{
  (e: 'update:modelValue', value: boolean): void;
}>();

const { locale } = useI18n();

const internalOpen = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val),
});

const copiedNumber = ref<string | null>(null);
let copyTimeout: ReturnType<typeof setTimeout> | null = null;

function handleContinue() {
  internalOpen.value = false;
}

function callNumber(number: string) {
  if (process.client) {
    window.open(`tel:${number}`, '_self');
  }
}

async function copyNumber(number: string) {
  try {
    await navigator.clipboard.writeText(number);
    copiedNumber.value = number;
    if (copyTimeout) clearTimeout(copyTimeout);
    copyTimeout = setTimeout(() => {
      copiedNumber.value = null;
    }, 2000);
  } catch (err) {
    // Fallback for older browsers
    const textArea = document.createElement('textarea');
    textArea.value = number;
    textArea.style.position = 'fixed';
    textArea.style.left = '-9999px';
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand('copy');
    document.body.removeChild(textArea);
    copiedNumber.value = number;
    if (copyTimeout) clearTimeout(copyTimeout);
    copyTimeout = setTimeout(() => {
      copiedNumber.value = null;
    }, 2000);
  }
}

onUnmounted(() => {
  if (copyTimeout) clearTimeout(copyTimeout);
});
</script>