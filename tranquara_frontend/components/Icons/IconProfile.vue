<template>
  <!-- Abstract person silhouette -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <!-- Head -->
    <circle cx="12" cy="7" r="3.5" :fill="active ? '#F59E0B' : 'currentColor'"/>
    <!-- Shoulders / body -->
    <path d="M5 20 C5.5 15.5 8.5 13.5 12 13.5 C15.5 13.5 18.5 15.5 19 20Z"
      :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.7"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
