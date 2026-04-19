<template>
  <nav class="fixed bottom-0 left-0 w-full bg-elevated border-t z-50 lg:hidden pb-[env(safe-area-inset-bottom)] pl-[env(safe-area-inset-left)] pr-[env(safe-area-inset-right)]">
    <div class="flex h-16 items-center justify-around px-2">
      <NuxtLink
        v-for="item in bottomNavSchema"
        :key="item.link"
        :to="item.link"
        class="flex flex-col items-center justify-center flex-1 h-full gap-1 transition-colors"
        :class="isActive(item.link) ? 'text-[#F59E0B]' : 'text-muted'"
      >
        <component 
          :is="resolveNavIcon(item.icon)"
          :size="24"
          :active="isActive(item.link)"
          :stroke-width="isActive(item.link) ? 2.5 : 2"
        />
        <span class="text-xs font-medium">{{ $t(item.titleKey) }}</span>
      </NuxtLink>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { bottomNavSchema } from "./bottomNavSchema";
import { resolveNavIcon } from "./navIcons";

const route = useRoute();

const isActive = (link: string) => {
  if (link === '/') {
    return route.path === '/';
  }
  return route.path.startsWith(link);
};
</script>
