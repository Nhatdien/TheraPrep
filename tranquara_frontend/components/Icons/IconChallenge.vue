<template>
  <svg :width="size" :height="size" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M15.5 2H8a2 2 0 0 0-2 2v3.5" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M15.5 2v3.5" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M15.5 2h.5a2 2 0 0 1 2 2v.5" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M19 8v8a2 2 0 0 1-2 2h-3.5" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M15.5 18v3.5" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M15.5 18H8a2 2 0 0 1-2-2v-3.5" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M4 12V8a2 2 0 0 1 2-2h3.5" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M8 6h.5a2 2 0 0 1 2 2v.5" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M10.5 8.5v3" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
    <path d="M15.5 12.5v-3" :stroke="active ? '#F59E0B' : 'currentColor'" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>
</template>
<script setup lang="ts">
withDefaults(defineProps<{ size?: number; active?: boolean }>(), { size: 24, active: false });
</script>
