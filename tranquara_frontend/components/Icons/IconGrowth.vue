<template>
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M7 20h10" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round"/>
    <path d="M10 20c0-4 2-8 6-10" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M12 20V10" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M12 10a5 5 0 0 1 5-5" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M12 10a5 5 0 0 0-5-5" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <ellipse cx="12" cy="10" rx="3" ry="2.5" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.15"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
