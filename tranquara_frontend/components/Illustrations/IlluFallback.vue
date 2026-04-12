<template>
  <!-- Fallback: brand mark repeated, amber tinted -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <g transform="translate(60,60)">
      <rect x="-8" y="-32" width="16" height="34" rx="8" fill="#F59E0B" transform="rotate(0)" opacity="1"/>
      <rect x="-8" y="-32" width="16" height="34" rx="8" fill="#F59E0B" transform="rotate(72)" opacity="0.8"/>
      <rect x="-8" y="-32" width="16" height="34" rx="8" fill="#F59E0B" transform="rotate(144)" opacity="0.6"/>
      <rect x="-8" y="-32" width="16" height="34" rx="8" fill="#F59E0B" transform="rotate(216)" opacity="0.45"/>
      <rect x="-8" y="-32" width="16" height="34" rx="8" fill="#F59E0B" transform="rotate(288)" opacity="0.3"/>
      <circle cx="0" cy="0" r="8" fill="#F59E0B"/>
    </g>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
