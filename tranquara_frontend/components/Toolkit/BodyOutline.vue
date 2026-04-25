<template>
  <svg
    viewBox="0 0 120 280"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    class="w-full max-w-[140px]"
    v-bind="$attrs"
  >
    <!-- Head -->
    <circle
      cx="60" cy="28" r="18"
      :fill="getFill('head')"
      :stroke="getStroke('head')"
      stroke-width="2"
      :class="getAnimClass('head')"
    />

    <!-- Neck -->
    <rect x="54" y="46" width="12" height="12" rx="4" fill="#3F3F46" />

    <!-- Shoulders + Chest area -->
    <path
      d="M20 70 Q20 58 40 58 L80 58 Q100 58 100 70 L100 110 Q100 120 90 120 L30 120 Q20 120 20 110 Z"
      :fill="getFill('shoulders', 'chest')"
      :stroke="getStroke('shoulders', 'chest')"
      stroke-width="2"
      :class="getAnimClass('shoulders', 'chest')"
    />

    <!-- Arms left -->
    <path
      d="M20 68 Q8 72 6 110 Q4 130 10 140 L16 140 Q18 130 18 110 L20 80"
      :fill="getFill('arms')"
      :stroke="getStroke('arms')"
      stroke-width="2"
      :class="getAnimClass('arms')"
    />

    <!-- Arms right -->
    <path
      d="M100 68 Q112 72 114 110 Q116 130 110 140 L104 140 Q102 130 102 110 L100 80"
      :fill="getFill('arms')"
      :stroke="getStroke('arms')"
      stroke-width="2"
      :class="getAnimClass('arms')"
    />

    <!-- Stomach -->
    <path
      d="M30 120 L90 120 Q95 120 95 130 L95 168 Q95 178 85 178 L35 178 Q25 178 25 168 L25 130 Q25 120 30 120"
      :fill="getFill('stomach')"
      :stroke="getStroke('stomach')"
      stroke-width="2"
      :class="getAnimClass('stomach')"
    />

    <!-- Legs left -->
    <path
      d="M30 178 L30 232 Q30 240 36 240 L50 240 Q54 240 54 236 L54 178"
      :fill="getFill('legs')"
      :stroke="getStroke('legs')"
      stroke-width="2"
      :class="getAnimClass('legs')"
    />

    <!-- Legs right -->
    <path
      d="M66 178 L66 236 Q66 240 70 240 L84 240 Q90 240 90 232 L90 178"
      :fill="getFill('legs')"
      :stroke="getStroke('legs')"
      stroke-width="2"
      :class="getAnimClass('legs')"
    />

    <!-- Feet left -->
    <path
      d="M30 240 L54 240 L54 254 Q54 262 46 262 L24 262 Q18 262 18 256 L18 250 Q18 240 30 240"
      :fill="getFill('feet')"
      :stroke="getStroke('feet')"
      stroke-width="2"
      :class="getAnimClass('feet')"
    />

    <!-- Feet right -->
    <path
      d="M66 240 L90 240 Q102 240 102 250 L102 256 Q102 262 96 262 L74 262 Q66 262 66 254 Z"
      :fill="getFill('feet')"
      :stroke="getStroke('feet')"
      stroke-width="2"
      :class="getAnimClass('feet')"
    />
  </svg>
</template>

<script lang="ts" setup>
defineOptions({ inheritAttrs: false });

const props = defineProps<{
  activePart: string;
  isComplete?: boolean;
}>();

const accentColor = '#F59E0B';
const accentFill = '#F59E0B20';
const completeFill = '#10B98120';
const completeStroke = '#10B981';

const isActive = (...parts: string[]) => parts.includes(props.activePart);

const getFill = (...parts: string[]) => {
  if (props.isComplete) return completeFill;
  return isActive(...parts) ? accentFill : '#27272A';
};

const getStroke = (...parts: string[]) => {
  if (props.isComplete) return completeStroke;
  return isActive(...parts) ? accentColor : '#3F3F46';
};

const getAnimClass = (...parts: string[]) => {
  if (props.isComplete) return 'transition-all duration-700';
  return isActive(...parts) ? 'transition-all duration-500 animate-body-pulse' : 'transition-all duration-500';
};
</script>

<style scoped>
@keyframes body-pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.7; }
}
.animate-body-pulse {
  animation: body-pulse 2s ease-in-out infinite;
}
</style>
