<template>
  <!-- Database / your data: stacked cylinder layers -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <!-- Top ellipse -->
    <ellipse cx="12" cy="6" rx="7" ry="2.5" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.9"/>
    <!-- Side walls -->
    <rect x="5" y="6" width="14" height="12" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.15"/>
    <!-- Bottom ellipse -->
    <ellipse cx="12" cy="18" rx="7" ry="2.5" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.5" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.4"/>
    <!-- Mid ring line -->
    <path d="M5 12 Q12 14.5 19 12" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.3" fill="none" opacity="0.6"/>
    <!-- Outline left + right -->
    <line x1="5" y1="6" x2="5" y2="18" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.4"/>
    <line x1="19" y1="6" x2="19" y2="18" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.4"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
