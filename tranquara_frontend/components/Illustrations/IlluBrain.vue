<template>
  <!-- Stacked wavy lines forming brain silhouette, geometric -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <!-- Brain silhouette via rounded rect -->
    <rect x="22" y="30" width="76" height="60" rx="30" fill="#F59E0B" opacity="0.15"/>
    <!-- Wavy horizontal layers suggesting brain folds -->
    <path d="M30 45 Q45 38 60 45 Q75 52 90 45" stroke="#F59E0B" stroke-width="5" stroke-linecap="round" fill="none"/>
    <path d="M28 57 Q44 50 60 57 Q76 64 92 57" stroke="#F59E0B" stroke-width="5" stroke-linecap="round" fill="none" opacity="0.85"/>
    <path d="M30 69 Q45 62 60 69 Q75 76 90 69" stroke="#F59E0B" stroke-width="5" stroke-linecap="round" fill="none" opacity="0.65"/>
    <path d="M36 80 Q50 73 64 80 Q74 85 82 80" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round" fill="none" opacity="0.4"/>
    <!-- Center dividing line -->
    <rect x="58" y="32" width="4" height="56" rx="2" fill="#FFFFFF" opacity="0.2"/>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
