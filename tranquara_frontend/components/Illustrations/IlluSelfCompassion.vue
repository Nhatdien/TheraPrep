<template>
  <!-- Abstract human figure in a self-hug, warmth glow behind -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <!-- Warm glow behind figure -->
    <circle cx="60" cy="62" r="34" fill="#FFFFFF" opacity="0.06"/>
    <circle cx="60" cy="62" r="24" fill="#FFFFFF" opacity="0.08"/>
    <!-- Head -->
    <circle cx="60" cy="36" r="13" fill="#F59E0B"/>
    <!-- Body -->
    <rect x="46" y="52" width="28" height="40" rx="14" fill="#F59E0B"/>
    <!-- Left arm wrapping around (self-hug) -->
    <rect x="38" y="56" width="22" height="8" rx="4" fill="#F59E0B" opacity="0.85" transform="rotate(25 49 60)"/>
    <!-- Right arm wrapping around (self-hug) -->
    <rect x="60" y="56" width="22" height="8" rx="4" fill="#F59E0B" opacity="0.85" transform="rotate(-25 71 60)"/>
    <!-- Sparkle above head -->
    <rect x="59" y="14" width="2" height="10" rx="1" fill="#FFFFFF" opacity="0.8"/>
    <rect x="54" y="18" width="12" height="2" rx="1" fill="#FFFFFF" opacity="0.8"/>
    <!-- Small accent dots -->
    <circle cx="38" cy="42" r="1.5" fill="#FFFFFF" opacity="0.4"/>
    <circle cx="82" cy="46" r="1.5" fill="#FFFFFF" opacity="0.3"/>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
