<template>
  <!-- Concentric ripple circles, like breath expanding outward -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <!-- Ripple rings (outermost faintest) -->
    <circle cx="60" cy="60" r="48" stroke="#F59E0B" stroke-width="3" fill="none" opacity="0.15"/>
    <circle cx="60" cy="60" r="38" stroke="#F59E0B" stroke-width="4" fill="none" opacity="0.3"/>
    <circle cx="60" cy="60" r="28" stroke="#F59E0B" stroke-width="5" fill="none" opacity="0.5"/>
    <circle cx="60" cy="60" r="18" stroke="#F59E0B" stroke-width="5" fill="none" opacity="0.7"/>
    <circle cx="60" cy="60" r="9" fill="#F59E0B"/>
    <!-- Small white accent dots on the outer ring -->
    <circle cx="60" cy="12" r="3" fill="#FFFFFF" opacity="0.5"/>
    <circle cx="108" cy="60" r="3" fill="#FFFFFF" opacity="0.4"/>
    <circle cx="60" cy="108" r="3" fill="#FFFFFF" opacity="0.3"/>
    <circle cx="12" cy="60" r="3" fill="#FFFFFF" opacity="0.4"/>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
