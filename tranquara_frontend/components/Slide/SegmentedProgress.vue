<template>
  <div
    class="segmented-progress"
    role="progressbar"
    :aria-valuemin="1"
    :aria-valuemax="total"
    :aria-valuenow="current"
    :style="{ '--segment-count': String(total) }"
  >
    <span
      v-for="segment in total"
      :key="segment"
      class="segment"
      :class="{ 'segment-active': segment <= current }"
    />
  </div>
</template>

<script setup lang="ts">
defineProps({
  current: {
    type: Number,
    required: true,
  },
  total: {
    type: Number,
    required: true,
  },
});
</script>

<style scoped>
.segmented-progress {
  display: grid;
  grid-template-columns: repeat(var(--segment-count), minmax(0, 1fr));
  gap: 0.4rem;
}

.segment {
  display: block;
  height: 0.24rem;
  border-radius: 9999px;
  background-color: rgba(var(--ui-color-neutral-400), 0.3);
  transition: background-color var(--motion-standard) var(--motion-ease-standard);
}

.segment-active {
  background-color: rgb(var(--ui-primary));
}
</style>
