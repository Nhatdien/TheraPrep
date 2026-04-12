<template>
  <!-- Concentric expanding circles — breath -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <circle cx="12" cy="12" r="10" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.5" fill="none" opacity="0.25"/>
    <circle cx="12" cy="12" r="6.5" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" fill="none" opacity="0.55"/>
    <circle cx="12" cy="12" r="3.5" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="2" fill="none" opacity="0.8"/>
    <circle cx="12" cy="12" r="1.5" :fill="active ? '#F59E0B' : 'currentColor'"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
