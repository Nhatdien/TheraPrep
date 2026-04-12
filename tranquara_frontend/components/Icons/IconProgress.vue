<template>
  <!-- Ascending bar chart, geometric -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <!-- Bars (left to right, ascending height) -->
    <rect x="3"  y="16" width="4" height="5"  rx="1.2" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.4"/>
    <rect x="9"  y="12" width="4" height="9"  rx="1.2" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.65"/>
    <rect x="15" y="7"  width="4" height="14" rx="1.2" :fill="active ? '#F59E0B' : 'currentColor'" opacity="1"/>
    <!-- Baseline -->
    <rect x="2" y="21" width="18" height="1.5" rx="0.75" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.3"/>
    <!-- Star above tallest bar -->
    <circle cx="17" cy="5" r="1.5" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.9"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
