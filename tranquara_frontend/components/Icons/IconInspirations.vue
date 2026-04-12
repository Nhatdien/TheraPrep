<template>
  <!-- Heart hands — therapy / toolkit icon -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <!-- Two hands cupping a heart -->
    <path d="M7 14c-2 0-4-1-4-3.5C3 8.5 5 7 7 8" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" fill="none"/>
    <path d="M17 14c2 0 4-1 4-3.5C21 8.5 19 7 17 8" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" fill="none"/>
    <path d="M7 14h10v2.5A4.5 4.5 0 0 1 12 21a4.5 4.5 0 0 1-5-4.5V14Z" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.2" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.6"/>
    <path d="M12 10 C12 10 9 7 9 5.5a2.5 2.5 0 0 1 3-2.4A2.5 2.5 0 0 1 15 5.5C15 7 12 10 12 10Z" :fill="active ? '#F59E0B' : 'currentColor'"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
