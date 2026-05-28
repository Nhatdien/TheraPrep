<template>
  <div class="flex items-center justify-center">
    <div class="w-full max-w-md">
      <h2 class="text-xl sm:text-2xl font-semibold text-highlighted mb-2 text-center">{{ displayTitle }}</h2>
      <p class="text-sm text-muted text-center mb-5">{{ displayContent }}</p>

      <!-- CTA Card linking to another slide group -->
      <div
        v-if="targetSlideGroup"
        @click="openSlideGroup(content?.config?.slide_group_id || content?.slide_group_id, content?.config?.collection_id || content?.collection_id)"
        class="p-5 rounded-2xl border border-default bg-elevated cursor-pointer hover:bg-accented hover:shadow-md transition-all"
      >
        <div class="flex items-start gap-3">
          <div class="w-10 h-10 rounded-xl bg-primary/10 flex items-center justify-center shrink-0">
            <Icon name="i-lucide-book-open" class="w-5 h-5 text-primary" />
          </div>
          <div class="flex-1 min-w-0">
            <h3 class="font-semibold text-highlighted text-sm">{{ targetSlideGroup.title }}</h3>
            <p v-if="targetSlideGroup.description" class="text-xs text-muted mt-1 line-clamp-2">{{ targetSlideGroup.description }}</p>
          </div>
          <Icon name="i-lucide-chevron-right" class="w-4 h-4 text-muted shrink-0 mt-1" />
        </div>
      </div>

      <!-- Fallback when slide group not found -->
      <div
        v-else
        @click="openSlideGroup(content?.config?.slide_group_id || content?.slide_group_id, content?.config?.collection_id || content?.collection_id)"
        class="p-5 rounded-2xl border border-default bg-elevated cursor-pointer hover:bg-accented hover:shadow-md transition-all text-center"
      >
        <Icon name="i-lucide-arrow-right-circle" class="w-8 h-8 text-primary mx-auto mb-2" />
        <p class="text-sm font-medium text-highlighted">{{ $t('common.next') }}</p>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
const { locale } = useI18n();
const { openSlideGroup, findSlideGroup } = useSlideGroup();

const props = defineProps({
  content: {
    type: Object,
    required: true,
  },
});

const displayTitle = computed(() => {
  if (locale.value === 'vi' && props.content?.title_vi) return props.content.title_vi;
  return props.content?.title || props.content?.headline || '';
});

const displayContent = computed(() => {
  if (locale.value === 'vi' && props.content?.content_vi) return props.content.content_vi;
  return props.content?.content || props.content?.subtext || '';
});

const targetSlideGroup = computed(() => {
  const collectionId = props.content?.config?.collection_id || props.content?.collection_id;
  const slideGroupId = props.content?.config?.slide_group_id || props.content?.slide_group_id;
  if (!collectionId || !slideGroupId) return undefined;
  return findSlideGroup(collectionId, slideGroupId);
});
</script>
