<template>
  <section class="px-4 py-6 pb-20 lg:pb-0">
    <DesktopBreadcrumb :items="breadcrumbs" />

    <!-- Back Button (mobile) -->
    <div class="flex items-center gap-3 mb-6">
      <button
        class="text-muted hover:text-highlighted transition-colors lg:hidden"
        @click="$router.back()">
        <ChevronLeft class="w-5 h-5" />
      </button>
      <!-- Title -->
      <div class="py-2">
        <h1 class="text-3xl font-bold text-highlighted">
          {{ $t("profile.title") }}
        </h1>
      </div>
    </div>

    <!-- Account Card (avatar, name, email) -->
    <SettingsAccountSection />

    <!-- ─── PERSONALIZE ──────────────────────────────────────────── -->
    <div class="mt-8">
      <h2
        class="text-xs font-semibold text-muted uppercase tracking-[0.2em] text-center mb-4">
        {{ $t("profile.personalize") }}
      </h2>
      <UCard>
        <div class="divide-y divide-default">
          <SettingsNavItem
            :icon="IconPalette"
            :label="$t('profile.personalize')"
            :subtitle="themeLabel"
            @click="openSection('theme')" />
          <SettingsNavItem
            :icon="IconPersonCircle"
            :label="$t('profile.aboutYou')"
            :subtitle="$t('profile.aboutYouSubtitle')"
            @click="openSection('about-you')" />
        </div>
      </UCard>
    </div>

    <!-- ─── ACCOUNT ──────────────────────────────────────────────── -->
    <div class="mt-8">
      <h2
        class="text-xs font-semibold text-muted uppercase tracking-[0.2em] text-center mb-4">
        {{ $t("profile.account") }}
      </h2>
      <UCard>
        <div class="divide-y divide-default">
          <SettingsNavItem
            :icon="IconBell"
            :label="$t('profile.notifications')"
            :subtitle="$t('profile.notificationsSubtitle')"
            @click="openSection('notifications')" />
          <SettingsNavItem
            :icon="IconDatabase"
            :label="$t('profile.yourData')"
            :subtitle="$t('profile.yourDataSubtitle')"
            @click="openSection('data')" />
        </div>
      </UCard>
    </div>

    <!-- Logout -->
    <div class="mt-8">
      <SettingsLogoutSection />
    </div>

    <!-- App Info -->
    <div class="text-center py-6 space-y-3">
      <div class="flex flex-col items-center gap-1">
        <BrandLogoMark :size="36" color="#F59E0B" variant="mark" />
        <p
          class="text-xs text-muted tracking-widest uppercase"
          style="letter-spacing: 0.15em">
          {{ $t("profile.appVersion", { version: "1.0.0" }) }}
        </p>
      </div>
      <div class="flex items-center justify-center gap-3">
        <UButton to="/terms" size="xs" color="neutral" variant="link">{{
          $t("profile.terms")
        }}</UButton>
        <span class="text-dimmed">•</span>
        <UButton to="/privacy" size="xs" color="neutral" variant="link">{{
          $t("profile.privacy")
        }}</UButton>
        <span class="text-dimmed">•</span>
        <UButton to="/support" size="xs" color="neutral" variant="link">{{
          $t("profile.support")
        }}</UButton>
      </div>
    </div>

    <!-- ─── Desktop Slideover Drawers ──────────────────────────────── -->
    <SettingsDetailView
      v-model:open="drawers.theme"
      :title="$t('profile.personalize')">
      <SettingsPersonalizationSection />
    </SettingsDetailView>

    <SettingsDetailView
      v-model:open="drawers.aboutYou"
      :title="$t('profile.aboutYou')">
      <div class="space-y-8">
        <SettingsAIPrivacySection />
        <USeparator />
        <SettingsMemoriesSection />
      </div>
    </SettingsDetailView>

    <SettingsDetailView
      v-model:open="drawers.notifications"
      :title="$t('profile.notifications')">
      <SettingsNotificationSection />
    </SettingsDetailView>

    <SettingsDetailView
      v-model:open="drawers.data"
      :title="$t('profile.yourData')">
      <div class="space-y-6">
        <div class="space-y-4">
          <h2
            class="text-sm font-semibold text-muted uppercase tracking-wider px-1">
            {{ $t("profile.dataSync") }}
          </h2>
          <SyncStatusDashboard
            :show-stats="true"
            :show-history="true"
            :show-actions="true" />
        </div>
        <SettingsDataManagementSection />
      </div>
    </SettingsDetailView>
  </section>
</template>

<script setup lang="ts">
import type { BreadcrumbItem } from "@nuxt/ui";
import { ChevronLeft } from "lucide-vue-next";
import IconPalette from "~/components/Icons/IconPalette.vue";
import IconPersonCircle from "~/components/Icons/IconPersonCircle.vue";
import IconBell from "~/components/Icons/IconBell.vue";
import IconDatabase from "~/components/Icons/IconDatabase.vue";
import DesktopBreadcrumb from "~/components/Common/DesktopBreadcrumb.vue";
import { useWindowSize } from "@vueuse/core";

definePageMeta({
  layout: "detail",
});

const { width } = useWindowSize();
const isMobile = computed(() => width.value < 768);
const { t: $t } = useI18n();

const breadcrumbs = computed<BreadcrumbItem[]>(() => [
  { label: $t("profile.title") },
]);

// ─── Drawer State (desktop only) ────────────────────────────────────────────
const drawers = reactive({
  theme: false,
  aboutYou: false,
  notifications: false,
  data: false,
});

type SectionKey = "theme" | "about-you" | "notifications" | "data";

const drawerMap: Record<SectionKey, keyof typeof drawers> = {
  theme: "theme",
  "about-you": "aboutYou",
  notifications: "notifications",
  data: "data",
};

const openSection = (section: SectionKey) => {
  if (isMobile.value) {
    navigateTo(`/profile/${section}`);
  } else {
    // Close all other drawers first
    Object.keys(drawers).forEach((key) => {
      drawers[key as keyof typeof drawers] = false;
    });
    drawers[drawerMap[section]] = true;
  }
};

// ─── Theme Label (for nav item subtitle) ─────────────────────────────────────
const settingsStore = useSettingsStore();

const themeLabel = computed(() => {
  return settingsStore.theme === "auto"
    ? $t("settings.themeOptions.auto")
    : settingsStore.theme === "light"
      ? $t("settings.themeOptions.light")
      : $t("settings.themeOptions.dark");
});
</script>
