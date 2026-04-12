<template>
  <!-- Crescent + layered concentric arcs -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <!-- Outer arc -->
    <path d="M 28 60 A 38 38 0 0 1 92 60" stroke="#F59E0B" stroke-width="6" stroke-linecap="round" fill="none" opacity="0.3"/>
    <!-- Mid arc -->
    <path d="M 36 60 A 28 28 0 0 1 84 60" stroke="#F59E0B" stroke-width="6" stroke-linecap="round" fill="none" opacity="0.55"/>
    <!-- Inner arc -->
    <path d="M 44 60 A 18 18 0 0 1 76 60" stroke="#F59E0B" stroke-width="6" stroke-linecap="round" fill="none" opacity="0.8"/>
    <!-- Crescent moon -->
    <circle cx="60" cy="46" r="18" fill="#F59E0B"/>
    <circle cx="68" cy="40" r="15" fill="#18181b"/>
    <!-- Stars -->
    <circle cx="88" cy="32" r="3" fill="#FFFFFF"/>
    <circle cx="76" cy="24" r="2" fill="#FFFFFF" opacity="0.7"/>
    <circle cx="96" cy="50" r="2" fill="#FFFFFF" opacity="0.5"/>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
