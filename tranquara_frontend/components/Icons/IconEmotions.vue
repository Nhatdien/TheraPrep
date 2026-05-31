<template>
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M19 14c1.49-1.46 2-3.01 2-4.5 0-2.49-2.01-4.5-4.5-4.5-1.29 0-2.46.55-3.25 1.45L12 7.5l-1.25-1.05A4.48 4.48 0 0 0 7.5 5C5.01 5 3 7.01 3 9.5c0 1.49.51 3.04 2 4.5l7 7Z" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.2" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
