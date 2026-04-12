<template>
  <aside class="hidden lg:flex flex-col fixed left-0 top-0 h-screen w-64 bg-elevated border-r border-default z-50">
    <!-- Brand mark -->
    <div class="px-6 py-6">
      <NuxtLink to="/" class="flex items-center gap-3">
        <BrandLogoMark :size="36" color="#F59E0B" variant="mark" />
        <span class="text-base font-bold tracking-widest uppercase text-highlighted" style="letter-spacing:0.15em;">Tranquara</span>
      </NuxtLink>
    </div>

    <!-- New Journal Action -->
    <div class="px-3 mb-4">
      <UButton
        block
        color="primary"
        variant="solid"
        size="md"
        class="justify-start gap-2"
        @click="navigateTo('/journaling')"
      >
        <IconQuickJournal :size="18" />
        <span>{{ $t('nav.newJournal') }}</span>
      </UButton>
    </div>

    <!-- Main Navigation -->
    <nav class="flex-1 px-3 space-y-1">
      <NuxtLink
        v-for="item in bottomNavSchema"
        :key="item.link"
        :to="item.link"
        class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors group focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/50"
        :class="isActive(item.link)
          ? 'text-[#F59E0B] bg-[#F59E0B]/10'
          : 'text-muted hover:bg-accented hover:text-default'
        "
      >
        <component
          :is="resolveNavIcon(item.icon)"
          :size="20"
          :active="isActive(item.link)"
        />
        <span class="text-sm font-medium">{{ $t(item.titleKey) }}</span>
      </NuxtLink>
    </nav>

    <!-- Bottom Section: Profile -->
    <div class="px-3 pb-4 border-t border-default pt-3">
      <NuxtLink
        to="/profile"
        class="flex items-center gap-3 px-3 py-2.5 rounded-lg transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/50"
        :class="isActive('/profile')
          ? 'text-[#F59E0B] bg-[#F59E0B]/10'
          : 'text-muted hover:bg-accented hover:text-default'
        "
      >
        <IconProfile :size="20" :active="isActive('/profile')" />
        <span class="text-sm font-medium">{{ $t('nav.profile') }}</span>
      </NuxtLink>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { bottomNavSchema } from "./bottomNavSchema";
import { PenLine } from "lucide-vue-next";
import { resolveNavIcon } from "./navIcons";
import IconProfile from '~/components/Icons/IconProfile.vue';
import IconQuickJournal from '~/components/Icons/IconQuickJournal.vue';

const route = useRoute();

const isActive = (link: string) => {
  if (link === '/') {
    return route.path === '/';
  }
  return route.path.startsWith(link);
};
</script>
