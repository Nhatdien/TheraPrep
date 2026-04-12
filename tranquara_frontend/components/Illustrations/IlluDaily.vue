<template>
  <!-- Sunburst with alternating rays, bold geometry -->
  <svg viewBox="0 0 120 120" fill="none" xmlns="http://www.w3.org/2000/svg" v-bind="$attrs">
    <rect width="120" height="120" rx="20" fill="#18181b"/>
    <g transform="translate(60,60)">
      <!-- Long rays -->
      <rect x="-4" y="-44" width="8" height="20" rx="4" fill="#F59E0B" transform="rotate(0)"/>
      <rect x="-4" y="-44" width="8" height="20" rx="4" fill="#F59E0B" transform="rotate(45)"/>
      <rect x="-4" y="-44" width="8" height="20" rx="4" fill="#F59E0B" transform="rotate(90)"/>
      <rect x="-4" y="-44" width="8" height="20" rx="4" fill="#F59E0B" transform="rotate(135)"/>
      <rect x="-4" y="-44" width="8" height="20" rx="4" fill="#F59E0B" transform="rotate(180)"/>
      <rect x="-4" y="-44" width="8" height="20" rx="4" fill="#F59E0B" transform="rotate(225)"/>
      <rect x="-4" y="-44" width="8" height="20" rx="4" fill="#F59E0B" transform="rotate(270)"/>
      <rect x="-4" y="-44" width="8" height="20" rx="4" fill="#F59E0B" transform="rotate(315)"/>
      <!-- Short rays (between long ones) -->
      <rect x="-3" y="-36" width="6" height="12" rx="3" fill="#FFFFFF" transform="rotate(22.5)" opacity="0.6"/>
      <rect x="-3" y="-36" width="6" height="12" rx="3" fill="#FFFFFF" transform="rotate(67.5)" opacity="0.6"/>
      <rect x="-3" y="-36" width="6" height="12" rx="3" fill="#FFFFFF" transform="rotate(112.5)" opacity="0.6"/>
      <rect x="-3" y="-36" width="6" height="12" rx="3" fill="#FFFFFF" transform="rotate(157.5)" opacity="0.6"/>
      <rect x="-3" y="-36" width="6" height="12" rx="3" fill="#FFFFFF" transform="rotate(202.5)" opacity="0.6"/>
      <rect x="-3" y="-36" width="6" height="12" rx="3" fill="#FFFFFF" transform="rotate(247.5)" opacity="0.6"/>
      <rect x="-3" y="-36" width="6" height="12" rx="3" fill="#FFFFFF" transform="rotate(292.5)" opacity="0.6"/>
      <rect x="-3" y="-36" width="6" height="12" rx="3" fill="#FFFFFF" transform="rotate(337.5)" opacity="0.6"/>
      <!-- Sun center -->
      <circle cx="0" cy="0" r="16" fill="#F59E0B"/>
    </g>
  </svg>
</template>
<script setup lang="ts">
defineOptions({ inheritAttrs: false });
</script>
