<template>
  <!-- Two abstract figure silhouettes side-by-side -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <!-- Figure 1 (amber) -->
    <circle cx="42" cy="38" r="12" fill="#F59E0B"/>
    <rect x="28" y="54" width="28" height="38" rx="14" fill="#F59E0B"/>
    <!-- Figure 2 (white) -->
    <circle cx="78" cy="38" r="12" fill="#FFFFFF" opacity="0.85"/>
    <rect x="64" y="54" width="28" height="38" rx="14" fill="#FFFFFF" opacity="0.85"/>
    <!-- Connecting heart between them -->
    <path d="M57 72 C57 68, 53 64, 50 68 C47 64, 43 68, 43 72 C43 76, 50 82, 50 82 C50 82, 57 76, 57 72Z"
      fill="#F59E0B" transform="translate(10, -4) scale(0.9)"/>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
