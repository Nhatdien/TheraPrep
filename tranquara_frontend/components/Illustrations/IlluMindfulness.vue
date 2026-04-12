<template>
  <!-- Lotus-like petal geometry, same language as brand mark -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <g transform="translate(60,58)">
      <!-- 6 petals in lotus arrangement -->
      <rect x="-7" y="-28" width="14" height="30" rx="7" fill="#F59E0B" transform="rotate(0)" opacity="1"/>
      <rect x="-7" y="-28" width="14" height="30" rx="7" fill="#F59E0B" transform="rotate(60)" opacity="0.85"/>
      <rect x="-7" y="-28" width="14" height="30" rx="7" fill="#F59E0B" transform="rotate(120)" opacity="0.7"/>
      <rect x="-7" y="-28" width="14" height="30" rx="7" fill="#FFFFFF" transform="rotate(180)" opacity="0.5"/>
      <rect x="-7" y="-28" width="14" height="30" rx="7" fill="#FFFFFF" transform="rotate(240)" opacity="0.4"/>
      <rect x="-7" y="-28" width="14" height="30" rx="7" fill="#FFFFFF" transform="rotate(300)" opacity="0.3"/>
      <circle cx="0" cy="0" r="7" fill="#F59E0B"/>
    </g>
    <!-- Ground base line -->
    <rect x="30" y="88" width="60" height="4" rx="2" fill="#F59E0B" opacity="0.3"/>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
