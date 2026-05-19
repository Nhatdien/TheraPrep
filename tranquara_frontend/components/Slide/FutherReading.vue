<template>
  <section>
    <h2 class="text-2xl sm:text-3xl font-semibold mb-2 text-highlighted">{{ $t('slide.furtherReading') }}</h2>
    <p class="text-sm text-toned mb-5">{{ $t('slide.furtherReadingDesc') }}</p>

    <!-- Structured links (config.links or contents array) -->
    <ul v-if="structuredLinks.length" class="space-y-3">
      <li
        class="rounded-xl border border-default/70 bg-elevated px-4 py-3"
        v-for="(item, index) in structuredLinks"
        :key="`${item?.link || item?.title || 'link'}-${index}`"
      >
        <p v-if="item?.type" class="text-xs uppercase tracking-wide text-toned mb-1">{{ item.type }}</p>
        <a class="text-sm sm:text-base font-medium text-primary underline underline-offset-2" :href="item?.link" target="_blank" rel="noopener noreferrer">
          {{ item.title || item?.link }}
        </a>
      </li>
    </ul>

    <!-- Fallback: parse links from HTML content -->
    <ul v-else-if="parsedLinks.length" class="space-y-3">
      <li
        class="rounded-xl border border-default/70 bg-elevated px-4 py-3"
        v-for="(item, index) in parsedLinks"
        :key="`parsed-${index}`"
      >
        <a class="text-sm sm:text-base font-medium text-primary underline underline-offset-2" :href="item.href" target="_blank" rel="noopener noreferrer">
          {{ item.text }}
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

const structuredLinks = computed(() => props.content?.config?.links || props.content?.contents || []);

const parsedLinks = computed(() => {
  const html = props.content?.content || '';
  if (!html) return [];
  const links: { href: string; text: string }[] = [];
  // Match <a href="...">text</a> patterns
  const regex = /<a\s+[^>]*href=["']([^"']+)["'][^>]*>(.*?)<\/a>/gi;
  let match;
  while ((match = regex.exec(html)) !== null) {
    links.push({ href: match[1], text: match[2].replace(/<[^>]*>/g, '') });
  }
  return links;
});
</script>
