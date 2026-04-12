<template>
  <!-- Simplified standing figure with scanning attention points -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <!-- Human figure outline (white, semi-transparent) -->
    <circle cx="54" cy="28" r="10" fill="#FFFFFF" opacity="0.35"/>
    <rect x="42" y="42" width="24" height="36" rx="12" fill="#FFFFFF" opacity="0.3"/>
    <rect x="44" y="78" width="8" height="22" rx="4" fill="#FFFFFF" opacity="0.25"/>
    <rect x="58" y="78" width="8" height="22" rx="4" fill="#FFFFFF" opacity="0.25"/>
    <!-- Scanning attention points (amber dots) -->
    <circle cx="54" cy="28" r="4" fill="#F59E0B" opacity="0.9"/>
    <circle cx="54" cy="50" r="4" fill="#F59E0B" opacity="0.75"/>
    <circle cx="54" cy="64" r="4" fill="#F59E0B" opacity="0.6"/>
    <circle cx="54" cy="82" r="4" fill="#F59E0B" opacity="0.45"/>
    <!-- Downward scan direction indicator (right side) -->
    <rect x="80" y="24" width="3" height="60" rx="1.5" fill="#F59E0B" opacity="0.2"/>
    <!-- Arrow tip -->
    <path d="M78 82 L81.5 90 L85 82" fill="#F59E0B" opacity="0.5"/>
    <!-- Scan labels (small dashes) -->
    <rect x="74" y="28" width="4" height="1.5" rx="0.75" fill="#F59E0B" opacity="0.4"/>
    <rect x="74" y="50" width="4" height="1.5" rx="0.75" fill="#F59E0B" opacity="0.4"/>
    <rect x="74" y="64" width="4" height="1.5" rx="0.75" fill="#F59E0B" opacity="0.4"/>
    <rect x="74" y="82" width="4" height="1.5" rx="0.75" fill="#F59E0B" opacity="0.4"/>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
