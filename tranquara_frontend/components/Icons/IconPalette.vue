<template>
  <!-- Theme/palette: 4 color swatches in a fan -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="3" y="12" width="18" height="8" rx="4" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.15" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.5"/>
    <!-- Color swatches -->
    <circle cx="7"  cy="16" r="2.2" :fill="active ? '#F59E0B' : 'currentColor'" opacity="1"/>
    <circle cx="12" cy="16" r="2.2" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.6"/>
    <circle cx="17" cy="16" r="2.2" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.35"/>
    <!-- Palette handle arc -->
    <path d="M8 12 Q12 4 16 12" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.6" stroke-linecap="round" fill="none"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
