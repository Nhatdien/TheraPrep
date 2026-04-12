<template>
  <article class="max-w-none">
    <p v-if="content?.subtitle" class="text-sm sm:text-base text-toned mb-5">
      {{ content?.subtitle }}
    </p>
    <div
      class="prose prose-sm sm:prose-base max-w-none text-default leading-7"
      v-html="content?.content || content?.body"></div>
  </article>
</template>

<script lang="ts" setup>
const props = defineProps({
  content: {
    type: Object,
    required: true,
  },
});
</script>
