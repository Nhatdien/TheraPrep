<template>
  <!-- Abstract hand with 5 lines (5 senses) -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <!-- Palm base -->
    <rect x="7" y="13" width="10" height="7" rx="3" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.2" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.5"/>
    <!-- 5 fingers -->
    <rect x="8"  y="7" width="2.2" height="8" rx="1.1" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.6"/>
    <rect x="10.9" y="5" width="2.2" height="9" rx="1.1" :fill="active ? '#F59E0B' : 'currentColor'"/>
    <rect x="13.8" y="6" width="2.2" height="8.5" rx="1.1" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.85"/>
    <rect x="16.4" y="8" width="2" height="7" rx="1" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.55"/>
    <rect x="5.6"  y="10" width="2" height="6" rx="1" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.45" transform="rotate(-15 6.6 13)"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
