<template>
  <div class="min-h-screen bg-gray-50 dark:bg-gray-950 flex">
    <!-- Sidebar -->
    <aside class="hidden lg:flex w-60 flex-col fixed inset-y-0 z-30 border-r border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900">
      <div class="flex items-center gap-2 px-4 h-14 border-b border-gray-200 dark:border-gray-800">
        <UIcon name="i-heroicons-cog-6-tooth" class="text-primary-500 w-5 h-5" />
        <span class="font-semibold text-sm">TheraPrep Admin</span>
      </div>

      <nav class="flex-1 px-2 py-4 space-y-1">
        <NuxtLink
          v-for="item in navItems"
          :key="item.to"
          :to="item.to"
          class="flex items-center gap-3 px-3 py-2 rounded-md text-sm transition-colors"
          :class="isActive(item.to) ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-600 dark:text-primary-400 font-medium' : 'text-gray-600 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800'"
        >
          <UIcon :name="item.icon" class="w-4 h-4" />
          {{ item.label }}
        </NuxtLink>
      </nav>

      <div class="px-4 py-3 border-t border-gray-200 dark:border-gray-800">
        <NuxtLink to="/" class="flex items-center gap-2 text-xs text-gray-500 hover:text-primary-500 transition-colors">
          <UIcon name="i-heroicons-arrow-left" class="w-3 h-3" />
          Back to App
        </NuxtLink>
      </div>
    </aside>

    <!-- Mobile header -->
    <div class="lg:hidden fixed top-0 inset-x-0 z-30 h-14 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 flex items-center px-4 gap-3">
      <UButton icon="i-heroicons-bars-3" variant="ghost" size="sm" @click="mobileMenuOpen = true" />
      <span class="font-semibold text-sm">Admin</span>
    </div>

    <!-- Mobile sidebar overlay -->
    <Teleport to="body">
      <div v-if="mobileMenuOpen" class="lg:hidden fixed inset-0 z-40">
        <div class="absolute inset-0 bg-black/50" @click="mobileMenuOpen = false" />
        <aside class="absolute inset-y-0 left-0 w-60 bg-white dark:bg-gray-900 shadow-xl">
          <div class="flex items-center justify-between px-4 h-14 border-b border-gray-200 dark:border-gray-800">
            <span class="font-semibold text-sm">Admin</span>
            <UButton icon="i-heroicons-x-mark" variant="ghost" size="xs" @click="mobileMenuOpen = false" />
          </div>
          <nav class="px-2 py-4 space-y-1">
            <NuxtLink
              v-for="item in navItems"
              :key="item.to"
              :to="item.to"
              class="flex items-center gap-3 px-3 py-2 rounded-md text-sm"
              :class="isActive(item.to) ? 'bg-primary-50 dark:bg-primary-900/20 text-primary-600 dark:text-primary-400 font-medium' : 'text-gray-600 dark:text-gray-400'"
              @click="mobileMenuOpen = false"
            >
              <UIcon :name="item.icon" class="w-4 h-4" />
              {{ item.label }}
            </NuxtLink>
          </nav>
        </aside>
      </div>
    </Teleport>

    <!-- Main content -->
    <div class="flex-1 lg:ml-60 pt-14 lg:pt-0">
      <main class="p-4 lg:p-8 max-w-7xl mx-auto">
        <slot />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
const route = useRoute();
const mobileMenuOpen = ref(false);

const navItems = [
  { to: '/admin', label: 'Dashboard', icon: 'i-heroicons-chart-bar-square' },
  { to: '/admin/collections', label: 'Collections', icon: 'i-heroicons-rectangle-stack' },
  { to: '/admin/import-export', label: 'Import / Export', icon: 'i-heroicons-arrow-down-tray' },
];

function isActive(to: string) {
  if (to === '/admin') return route.path === '/admin';
  return route.path.startsWith(to);
}
</script>
