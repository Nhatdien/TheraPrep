<template>
  <!-- Quick journal: pen writing on page -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <!-- Page -->
    <rect x="4" y="3" width="13" height="16" rx="2" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.1" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.5"/>
    <!-- Lines on page -->
    <rect x="7" y="7.5" width="7" height="1.4" rx="0.7" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.5"/>
    <rect x="7" y="10.5" width="5" height="1.4" rx="0.7" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.35"/>
    <!-- Pen tip (bottom-right, diagonal) -->
    <path d="M15 14 L20 9 L21.5 10.5 L16.5 15.5 Z" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.9"/>
    <line x1="15" y1="14" x2="14" y2="17" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.2" stroke-linecap="round"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
