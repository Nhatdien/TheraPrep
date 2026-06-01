<template>
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="m17 2 4 4-4 4" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M3 12V9a4 4 0 0 1 4-4h14" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="m7 22-4-4 4-4" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M21 12v3a4 4 0 0 1-4 4H3" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
