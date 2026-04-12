<template>
  <!-- Storm cloud → clear sky: geometric cloud shape with amber sun breaking through -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <!-- Cloud body (geometric flat) -->
    <rect x="20" y="52" width="80" height="32" rx="16" fill="#FFFFFF" opacity="0.15"/>
    <rect x="30" y="40" width="50" height="30" rx="15" fill="#FFFFFF" opacity="0.2"/>
    <rect x="46" y="32" width="34" height="26" rx="13" fill="#FFFFFF" opacity="0.25"/>
    <!-- Amber sun rays breaking from top-right -->
    <rect x="82" y="22" width="10" height="4" rx="2" fill="#F59E0B" transform="rotate(0 87 24)"/>
    <rect x="82" y="22" width="10" height="4" rx="2" fill="#F59E0B" transform="rotate(45 87 24)"/>
    <rect x="82" y="22" width="10" height="4" rx="2" fill="#F59E0B" transform="rotate(90 87 24)"/>
    <rect x="82" y="22" width="10" height="4" rx="2" fill="#F59E0B" transform="rotate(135 87 24)"/>
    <circle cx="87" cy="32" r="8" fill="#F59E0B"/>
    <!-- Rain drops (below cloud, transitioning to calm) -->
    <rect x="38" y="86" width="4" height="10" rx="2" fill="#FFFFFF" opacity="0.25"/>
    <rect x="52" y="90" width="4" height="8" rx="2" fill="#FFFFFF" opacity="0.15"/>
    <rect x="66" y="85" width="4" height="10" rx="2" fill="#FFFFFF" opacity="0.2"/>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
