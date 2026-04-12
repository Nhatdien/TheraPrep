<template>
  <!-- Abstract body scan: person silhouette with scan line -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <!-- Head -->
    <circle cx="12" cy="5.5" r="2.5" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.9"/>
    <!-- Body torso -->
    <rect x="9" y="9" width="6" height="9" rx="3" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.3" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.4"/>
    <!-- Scan line across mid -->
    <line x1="6" y1="14" x2="18" y2="14" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.5" stroke-linecap="round" opacity="0.85"/>
    <!-- Scan glow dots -->
    <circle cx="6" cy="14" r="1.2" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.7"/>
    <circle cx="18" cy="14" r="1.2" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.7"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
