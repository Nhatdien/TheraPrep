<template>
  <!-- Abstract open book with brand mark leaf top-right -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <!-- Book left page -->
    <path d="M12 5v14" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.5" stroke-linecap="round"/>
    <path d="M12 5C10 4 5 4 3 5v13c2-1 7-1 9 0Z" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.2" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.6" stroke-linejoin="round"/>
    <!-- Book right page -->
    <path d="M12 5C14 4 19 4 21 5v13c-2-1-7-1-9 0Z" :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.12" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.6" stroke-linejoin="round"/>
    <!-- Leaf mark tiny -->
    <g transform="translate(18,3) scale(0.55)">
      <rect x="-4" y="-8" width="8" height="9" rx="4" :fill="active ? '#F59E0B' : 'currentColor'" transform="rotate(0)" opacity="1"/>
      <rect x="-4" y="-8" width="8" height="9" rx="4" :fill="active ? '#F59E0B' : 'currentColor'" transform="rotate(120)" opacity="0.7"/>
      <rect x="-4" y="-8" width="8" height="9" rx="4" :fill="active ? '#F59E0B' : 'currentColor'" transform="rotate(240)" opacity="0.45"/>
      <circle cx="0" cy="0" r="3" :fill="active ? '#F59E0B' : 'currentColor'"/>
    </g>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
