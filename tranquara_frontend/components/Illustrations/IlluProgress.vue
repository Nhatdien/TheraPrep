<template>
  <!-- Ascending stepped shapes like a staircase with stars -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <!-- Staircase steps (ascending left→right) -->
    <rect x="18" y="78" width="22" height="24" rx="4" fill="#F59E0B" opacity="0.4"/>
    <rect x="44" y="62" width="22" height="40" rx="4" fill="#F59E0B" opacity="0.65"/>
    <rect x="70" y="44" width="22" height="58" rx="4" fill="#F59E0B"/>
    <!-- Star accents above each step -->
    <circle cx="29" cy="70" r="4" fill="#FFFFFF" opacity="0.5"/>
    <circle cx="55" cy="54" r="4" fill="#FFFFFF" opacity="0.7"/>
    <circle cx="81" cy="35" r="5" fill="#FFFFFF"/>
    <!-- Sparkle lines on top star -->
    <rect x="79" y="24" width="4" height="8" rx="2" fill="#FFFFFF" opacity="0.8"/>
    <rect x="79" y="24" width="4" height="8" rx="2" fill="#FFFFFF" opacity="0.6" transform="rotate(90 81 28)"/>
    <rect x="79" y="24" width="4" height="8" rx="2" fill="#FFFFFF" opacity="0.4" transform="rotate(45 81 28)"/>
    <rect x="79" y="24" width="4" height="8" rx="2" fill="#FFFFFF" opacity="0.4" transform="rotate(135 81 28)"/>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
