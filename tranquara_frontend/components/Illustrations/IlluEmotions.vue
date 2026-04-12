<template>
  <!-- Three abstract faces side-by-side representing emotional range -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <!-- Face 1 — sad (amber, low opacity) -->
    <circle cx="28" cy="58" r="16" fill="#F59E0B" opacity="0.4"/>
    <circle cx="23" cy="54" r="2.5" fill="#18181b"/>
    <circle cx="33" cy="54" r="2.5" fill="#18181b"/>
    <path d="M22 66 Q28 62 34 66" stroke="#18181b" stroke-width="2" stroke-linecap="round" fill="none"/>
    <!-- Face 2 — neutral (amber, medium opacity) -->
    <circle cx="60" cy="58" r="16" fill="#F59E0B" opacity="0.65"/>
    <circle cx="55" cy="54" r="2.5" fill="#18181b"/>
    <circle cx="65" cy="54" r="2.5" fill="#18181b"/>
    <rect x="54" y="64" width="12" height="2" rx="1" fill="#18181b"/>
    <!-- Face 3 — happy (amber, full) -->
    <circle cx="92" cy="58" r="16" fill="#F59E0B"/>
    <circle cx="87" cy="54" r="2.5" fill="#18181b"/>
    <circle cx="97" cy="54" r="2.5" fill="#18181b"/>
    <path d="M86 63 Q92 69 98 63" stroke="#18181b" stroke-width="2" stroke-linecap="round" fill="none"/>
    <!-- Small white heart above center face -->
    <path d="M60 32 C60 29, 56.5 26, 54 29 C51.5 26, 48 29, 48 32 C48 35, 54 40, 54 40 C54 40, 60 35, 60 32Z"
      fill="#FFFFFF" opacity="0.8" transform="translate(3, -2) scale(0.7)"/>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
