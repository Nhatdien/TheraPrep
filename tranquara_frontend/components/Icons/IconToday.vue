<template>
  <!-- Journal page with today-indicator dot -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <rect x="4" y="3" width="14" height="18" rx="3" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.15"/>
    <rect x="4" y="3" width="14" height="18" rx="3" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" fill="none"/>
    <rect x="7" y="8" width="8" height="1.5" rx="0.75" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.7"/>
    <rect x="7" y="11.5" width="6" height="1.5" rx="0.75" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.5"/>
    <!-- Today dot -->
    <circle cx="15" cy="5" r="2.5" :fill="active ? '#F59E0B' : 'currentColor'"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
