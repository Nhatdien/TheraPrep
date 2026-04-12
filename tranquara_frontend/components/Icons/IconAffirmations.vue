<template>
  <!-- Affirmations: sparkle burst + speech bubble -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <!-- Speech bubble -->
    <path d="M4 5a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H9l-3 3v-3H6a2 2 0 0 1-2-2V5Z"
      :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.15"
      :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.6"/>
    <!-- Star/sparkle inside -->
    <rect x="10.5" y="7" width="3" height="1.5" rx="0.75" :fill="active ? '#F59E0B' : 'currentColor'"/>
    <rect x="10.5" y="7" width="3" height="1.5" rx="0.75" :fill="active ? '#F59E0B' : 'currentColor'" transform="rotate(90 12 7.75)"/>
    <rect x="10.5" y="7" width="3" height="1.5" rx="0.75" :fill="active ? '#F59E0B' : 'currentColor'" transform="rotate(45 12 7.75)" opacity="0.7"/>
    <rect x="10.5" y="7" width="3" height="1.5" rx="0.75" :fill="active ? '#F59E0B' : 'currentColor'" transform="rotate(135 12 7.75)" opacity="0.7"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
