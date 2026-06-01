<template>
  <USlideover
    v-model:open="open"
    side="bottom"
    :overlay="true"
    :title="$t('journal.formatting')"
  >
    <template #body>
      <div class="px-4 pb-[calc(1rem+env(safe-area-inset-bottom))] space-y-4">
        <!-- Heading style selector -->
        <div class="flex bg-muted/20 dark:bg-white/5 rounded-xl p-1 gap-1">
          <button
            v-for="style in headingStyles"
            :key="style.key"
            @click="style.action()"
            class="flex-1 py-2 px-1 rounded-lg text-sm transition-all"
            :class="isHeadingActive(style.key)
              ? 'bg-background font-semibold text-highlighted shadow-sm'
              : 'text-muted hover:text-default'"
          >
            {{ style.label }}
          </button>
        </div>

        <!-- Format toggles -->
        <div class="flex gap-2 justify-around">
          <button
            @click="toggleFormat('bold')"
            class="w-12 h-12 rounded-xl flex items-center justify-center transition-colors"
            :class="isFormatActive('bold') ? 'bg-primary/20 text-primary' : 'bg-muted/10 text-default hover:bg-muted/20'"
          >
            <BoldIcon :size="20" :stroke-width="3" />
          </button>
          <button
            @click="toggleFormat('italic')"
            class="w-12 h-12 rounded-xl flex items-center justify-center transition-colors"
            :class="isFormatActive('italic') ? 'bg-primary/20 text-primary' : 'bg-muted/10 text-default hover:bg-muted/20'"
          >
            <ItalicIcon :size="20" />
          </button>
          <button
            @click="toggleFormat('underline')"
            class="w-12 h-12 rounded-xl flex items-center justify-center transition-colors"
            :class="isFormatActive('underline') ? 'bg-primary/20 text-primary' : 'bg-muted/10 text-default hover:bg-muted/20'"
          >
            <UnderlineIcon :size="20" />
          </button>
          <button
            @click="toggleFormat('strike')"
            class="w-12 h-12 rounded-xl flex items-center justify-center transition-colors"
            :class="isFormatActive('strike') ? 'bg-primary/20 text-primary' : 'bg-muted/10 text-default hover:bg-muted/20'"
          >
            <StrikethroughIcon :size="20" />
          </button>
        </div>
      </div>
    </template>
  </USlideover>
</template>

<script setup lang="ts">
import type { Editor } from '@tiptap/vue-3';
import {
  Bold as BoldIcon,
  Italic as ItalicIcon,
  Underline as UnderlineIcon,
  Strikethrough as StrikethroughIcon,
} from 'lucide-vue-next';

const props = defineProps<{ editor?: Editor }>();
const open = defineModel<boolean>();

// Track editor transactions for reactive isActive() calls
const tick = ref(0);
let cleanupListener: (() => void) | null = null;

watch(
  () => props.editor,
  (editor) => {
    cleanupListener?.();
    cleanupListener = null;
    if (editor) {
      const handler = () => { tick.value++; };
      editor.on('transaction', handler);
      cleanupListener = () => editor.off('transaction', handler);
    }
  },
  { immediate: true },
);

onUnmounted(() => { cleanupListener?.(); });

// Store state before drawer opens to restore after
let storedSelection: { from: number; to: number } | null = null;

watch(open, (val) => {
  if (val && props.editor) {
    // Store current selection before potential blur
    const { selection } = props.editor.state;
    if (selection.from !== selection.to) {
      storedSelection = { from: selection.from, to: selection.to };
    } else {
      storedSelection = null;
    }
    // Minimal approach: just hide mobile keyboard by blurring only on mobile
    // but don't clear selection by using a different approach
    if ('virtualKeyboard' in navigator && (window.navigator as any).virtualKeyboard?.overlaysContent) {
      props.editor.commands.blur();
    }
  } else if (!val) {
    nextTick(() => {
      props.editor?.commands.focus();
      // Restore selection if we had one
      if (storedSelection && props.editor) {
        props.editor.commands.setTextSelection(storedSelection);
        storedSelection = null;
      }
    });
  }
});

const headingStyles = [
  {
    key: 'title',
    label: 'Title',
    action: () => props.editor?.chain().focus().toggleHeading({ level: 1 }).run(),
  },
  {
    key: 'heading',
    label: 'Heading',
    action: () => props.editor?.chain().focus().toggleHeading({ level: 2 }).run(),
  },
  {
    key: 'subheading',
    label: 'Sub',
    action: () => props.editor?.chain().focus().toggleHeading({ level: 3 }).run(),
  },
  {
    key: 'body',
    label: 'Body',
    action: () => props.editor?.chain().focus().setParagraph().run(),
  },
];

const isHeadingActive = (key: string) => {
  tick.value; // reactive dependency
  if (!props.editor) return false;
  if (key === 'title') return props.editor.isActive('heading', { level: 1 });
  if (key === 'heading') return props.editor.isActive('heading', { level: 2 });
  if (key === 'subheading') return props.editor.isActive('heading', { level: 3 });
  if (key === 'body') return props.editor.isActive('paragraph');
  return false;
};

const isFormatActive = (format: string) => {
  tick.value; // reactive dependency
  return props.editor?.isActive(format) ?? false;
};

const toggleFormat = (format: string) => {
  if (!props.editor) return;
  // Don't call focus() - the editor already has focus and selection
  // We need to save and restore selection manually after the operation
  const { selection } = props.editor.state;
  const hasSelection = selection.from !== selection.to;
  const savedSelection = hasSelection ? { from: selection.from, to: selection.to } : null;
  
  const chain = props.editor.chain();
  if (format === 'bold') chain.toggleBold().run();
  else if (format === 'italic') chain.toggleItalic().run();
  else if (format === 'underline') chain.toggleUnderline().run();
  else if (format === 'strike') chain.toggleStrike().run();
  
  // Restore selection after format toggle
  if (savedSelection) {
    nextTick(() => {
      if (props.editor) {
        props.editor.commands.setTextSelection(savedSelection);
      }
    });
  }
};
</script>
