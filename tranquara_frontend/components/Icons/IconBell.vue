<template>
  <!-- Bell with subtle dot indicator -->
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <!-- Bell body -->
    <path d="M6 10 C6 7 8.7 4.5 12 4.5 C15.3 4.5 18 7 18 10 L18 14 L20 16 L4 16 L6 14 Z"
      :fill="active ? '#F59E0B' : 'currentColor'" opacity="0.2"
      :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.5" stroke-linejoin="round"/>
    <!-- Clapper -->
    <path d="M10 16 Q10 19 12 19 Q14 19 14 16" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.5" fill="none"/>
    <!-- Top knob -->
    <circle cx="12" cy="4.5" r="1.2" :fill="active ? '#F59E0B' : 'currentColor'"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
