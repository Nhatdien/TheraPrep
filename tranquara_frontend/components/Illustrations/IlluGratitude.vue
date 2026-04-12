<template>
  <!-- Two cupped hands holding a radiating light -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <!-- Left hand (tilted rounded rect) -->
    <rect x="30" y="58" width="30" height="12" rx="6" fill="#F59E0B" transform="rotate(-20 45 64)"/>
    <!-- Right hand -->
    <rect x="60" y="58" width="30" height="12" rx="6" fill="#F59E0B" transform="rotate(20 75 64)"/>
    <!-- Palm base connecting -->
    <rect x="44" y="72" width="32" height="10" rx="5" fill="#F59E0B" opacity="0.7"/>
    <!-- Radiating light above hands -->
    <circle cx="60" cy="42" r="8" fill="#F59E0B" opacity="0.9"/>
    <circle cx="60" cy="42" r="14" fill="#F59E0B" opacity="0.15"/>
    <!-- Light rays -->
    <rect x="59" y="24" width="2" height="8" rx="1" fill="#F59E0B" opacity="0.7"/>
    <rect x="59" y="24" width="2" height="8" rx="1" fill="#F59E0B" opacity="0.6" transform="rotate(60 60 42)"/>
    <rect x="59" y="24" width="2" height="8" rx="1" fill="#F59E0B" opacity="0.6" transform="rotate(-60 60 42)"/>
    <rect x="59" y="24" width="2" height="8" rx="1" fill="#F59E0B" opacity="0.5" transform="rotate(120 60 42)"/>
    <rect x="59" y="24" width="2" height="8" rx="1" fill="#F59E0B" opacity="0.5" transform="rotate(-120 60 42)"/>
    <!-- White light particles -->
    <circle cx="42" cy="36" r="1.5" fill="#FFFFFF" opacity="0.5"/>
    <circle cx="78" cy="38" r="1.5" fill="#FFFFFF" opacity="0.4"/>
    <circle cx="50" cy="28" r="1" fill="#FFFFFF" opacity="0.3"/>
    <circle cx="72" cy="30" r="1" fill="#FFFFFF" opacity="0.35"/>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
