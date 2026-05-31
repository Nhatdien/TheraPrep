<template>
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M9 18h6" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round"/>
    <path d="M10 22h4" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round"/>
    <path d="M15 14c.2-1 .7-1.7 1.5-2.5 1-1 1.5-2 1.5-3.5a6 6 0 0 0-12 0c0 1.5.5 2.5 1.5 3.5.8.8 1.3 1.5 1.5 2.5" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.15" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
