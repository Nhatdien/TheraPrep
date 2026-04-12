<template>
  <!-- Abstract quill: stacked overlapping leaf-rectangles forming a feather -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <!-- Quill shaft -->
    <rect x="55" y="30" width="10" height="60" rx="5" fill="#F59E0B"/>
    <!-- Overlapping leaf-barbs left -->
    <rect x="28" y="38" width="32" height="12" rx="6" fill="#F59E0B" transform="rotate(-28 44 44)" opacity="0.9"/>
    <rect x="28" y="52" width="28" height="11" rx="5" fill="#F59E0B" transform="rotate(-20 42 57)" opacity="0.75"/>
    <rect x="30" y="65" width="24" height="10" rx="5" fill="#F59E0B" transform="rotate(-12 42 70)" opacity="0.55"/>
    <!-- Overlapping leaf-barbs right -->
    <rect x="60" y="38" width="32" height="12" rx="6" fill="#FFFFFF" transform="rotate(28 76 44)" opacity="0.9"/>
    <rect x="64" y="52" width="28" height="11" rx="5" fill="#FFFFFF" transform="rotate(20 78 57)" opacity="0.75"/>
    <rect x="66" y="65" width="24" height="10" rx="5" fill="#FFFFFF" transform="rotate(12 78 70)" opacity="0.55"/>
    <!-- Nib tip -->
    <rect x="55" y="86" width="10" height="6" rx="3" fill="#F59E0B"/>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
