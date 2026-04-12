<template>
  <svg
    :width="size"
    :height="size"
    viewBox="0 0 80 80"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    :aria-label="variant === 'full' ? 'Tranquara' : undefined"
    role="img"
  >
    <!-- Abstract leaf cluster: 5 rotated rhombus shapes converging at apex -->
    <g transform="translate(40,40)">
      <!-- Petal 1 — upright -->
      <rect
        x="-6" y="-26" width="12" height="28"
        rx="6"
        :fill="color"
        transform="rotate(0)"
        opacity="1"
      />
      <!-- Petal 2 — rotated 72° -->
      <rect
        x="-6" y="-26" width="12" height="28"
        rx="6"
        :fill="color"
        transform="rotate(72)"
        opacity="0.85"
      />
      <!-- Petal 3 — rotated 144° -->
      <rect
        x="-6" y="-26" width="12" height="28"
        rx="6"
        :fill="color"
        transform="rotate(144)"
        opacity="0.7"
      />
      <!-- Petal 4 — rotated 216° -->
      <rect
        x="-6" y="-26" width="12" height="28"
        rx="6"
        :fill="color"
        transform="rotate(216)"
        opacity="0.55"
      />
      <!-- Petal 5 — rotated 288° -->
      <rect
        x="-6" y="-26" width="12" height="28"
        rx="6"
        :fill="color"
        transform="rotate(288)"
        opacity="0.4"
      />
      <!-- Center dot -->
      <circle cx="0" cy="0" r="5" :fill="color" />
    </g>

    <!-- Wordmark shown only when variant === 'full' -->
    <text
      v-if="variant === 'full'"
      x="40"
      y="74"
      text-anchor="middle"
      font-family="Nunito, sans-serif"
      font-weight="700"
      font-size="11"
      :fill="color"
      letter-spacing="2"
    >TRANQUARA</text>
  </svg>
</template>

<script setup lang="ts">
withDefaults(defineProps<{
  size?: number | string;
  color?: string;
  variant?: 'mark' | 'full';
}>(), {
  size: 48,
  color: '#F59E0B',
  variant: 'mark',
});
</script>
