<template>
  <!-- Calendar with a soft arc -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="3" y="5" width="18" height="16" rx="3" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.12" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.7"/>
    <!-- Header bar -->
    <rect x="3" y="5" width="18" height="5" rx="3" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.25"/>
    <!-- Pin lines -->
    <rect x="8" y="3" width="2" height="4" rx="1" :fill="active ? '#F59E0B' : 'currentColor'"/>
    <rect x="14" y="3" width="2" height="4" rx="1" :fill="active ? '#F59E0B' : 'currentColor'"/>
    <!-- Arc inside calendar -->
    <path d="M8 16 Q12 12 16 16" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="2" stroke-linecap="round" fill="none"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
