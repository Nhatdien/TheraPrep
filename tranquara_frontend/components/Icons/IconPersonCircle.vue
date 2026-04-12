<template>
  <!-- Person circle — about you -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <circle cx="12" cy="12" r="9" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.5" fill="none" opacity="0.4"/>
    <!-- Head -->
    <circle cx="12" cy="9.5" r="3" :fill="active ? '#F59E0B' : 'currentColor'"/>
    <!-- Shoulders -->
    <path d="M5.5 19.5 C6 15.5 9 14 12 14 C15 14 18 15.5 18.5 19.5" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.6"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
