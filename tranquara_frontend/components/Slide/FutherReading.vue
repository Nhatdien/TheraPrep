<template>
  <section>
    <h2 class="text-2xl sm:text-3xl font-semibold mb-2 text-highlighted">{{ $t('slide.furtherReading') }}</h2>
    <p class="text-sm text-toned mb-5">Curated references to keep your reflection going.</p>
    <ul class="space-y-3">
      <li
        class="rounded-xl border border-default/70 bg-elevated px-4 py-3"
        v-for="(item, index) in (content?.config?.links || content?.contents || [])"
        :key="`${item?.link || item?.title || 'link'}-${index}`"
      >
        <p v-if="item?.type" class="text-xs uppercase tracking-wide text-toned mb-1">{{ item.type }}</p>
        <a class="text-sm sm:text-base font-medium text-primary underline underline-offset-2" :href="item?.link" target="_blank" rel="noopener noreferrer">
          {{ item.title || item?.link }}
        </a>
      </li>
    </ul>
  </section>
</template>

<script lang="ts" setup>
const props = defineProps({
  content: {
    type: Object,
    required: true,
  },
});
</script>
