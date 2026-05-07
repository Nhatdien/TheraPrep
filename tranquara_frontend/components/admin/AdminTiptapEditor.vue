<template>
  <div class="tiptap-wrapper border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden focus-within:ring-2 focus-within:ring-primary-500 focus-within:border-primary-500 transition-all">
    <!-- Toolbar -->
    <div class="flex items-center gap-0.5 px-2 py-1.5 border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800/60 flex-wrap">
      <button type="button" @click="e?.chain().focus().toggleBold().run()" :class="active('bold')" class="tb" title="Bold"><strong>B</strong></button>
      <button type="button" @click="e?.chain().focus().toggleItalic().run()" :class="active('italic')" class="tb" title="Italic"><em>I</em></button>
      <button type="button" @click="e?.chain().focus().toggleStrike().run()" :class="active('strike')" class="tb" title="Strikethrough"><s>S</s></button>

      <div class="w-px h-4 bg-gray-200 dark:bg-gray-600 mx-1" />

      <button type="button" @click="e?.chain().focus().toggleHeading({ level: 2 }).run()" :class="active('heading', { level: 2 })" class="tb font-semibold" title="Heading 2 — click again to revert to paragraph">H2</button>
      <button type="button" @click="e?.chain().focus().toggleHeading({ level: 3 }).run()" :class="active('heading', { level: 3 })" class="tb font-semibold" title="Heading 3 — click again to revert to paragraph">H3</button>

      <div class="w-px h-4 bg-gray-200 dark:bg-gray-600 mx-1" />

      <button type="button" @click="e?.chain().focus().toggleBulletList().run()" :class="active('bulletList')" class="tb" title="Bullet list">• List</button>
      <button type="button" @click="e?.chain().focus().toggleOrderedList().run()" :class="active('orderedList')" class="tb" title="Ordered list">1. List</button>
      <button type="button" @click="e?.chain().focus().toggleBlockquote().run()" :class="active('blockquote')" class="tb" title="Blockquote">❝</button>

      <div class="w-px h-4 bg-gray-200 dark:bg-gray-600 mx-1" />

      <button type="button" @click="e?.chain().focus().clearNodes().unsetAllMarks().run()" class="tb text-gray-400" title="Clear all formatting">Clear</button>
    </div>
    <!-- Content -->
    <EditorContent :editor="editor" class="tiptap-content" />
  </div>
</template>

<script setup lang="ts">
import { useEditor, EditorContent } from '@tiptap/vue-3';
import StarterKit from '@tiptap/starter-kit';

const props = defineProps<{ modelValue?: string; placeholder?: string }>();
const emit = defineEmits<{ 'update:modelValue': [v: string] }>();

// tick is incremented on every editor transaction so isActive() re-evaluates reactively
const tick = ref(0);

const editor = useEditor({
  content: props.modelValue || '',
  extensions: [StarterKit],
  editorProps: {
    attributes: {
      class: 'prose prose-sm dark:prose-invert max-w-none outline-none min-h-[120px] px-3 py-3',
    },
  },
  onUpdate: ({ editor }) => {
    tick.value++;
    const html = editor.getHTML();
    emit('update:modelValue', html === '<p></p>' ? '' : html);
  },
  onSelectionUpdate: () => { tick.value++; },
});

// shorthand so template isn't verbose
const e = computed(() => editor.value);

watch(() => props.modelValue, (val) => {
  if (!editor.value) return;
  const current = editor.value.getHTML();
  const incoming = val || '';
  if (incoming !== current && !(incoming === '' && current === '<p></p>')) {
    editor.value.commands.setContent(incoming, false);
  }
});

onBeforeUnmount(() => editor.value?.destroy());

// Calling tick.value inside active() makes every button's class reactive to cursor/content changes
function active(type: string, attrs?: Record<string, unknown>) {
  tick.value; // reactive dependency — do NOT remove
  return editor.value?.isActive(type, attrs)
    ? 'bg-primary-100 dark:bg-primary-900/40 text-primary-700 dark:text-primary-300 ring-1 ring-primary-400/40'
    : 'text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-white';
}
</script>

<style scoped>
.tb {
  padding: 3px 7px;
  border-radius: 5px;
  font-size: 0.75rem;
  transition: background-color 0.15s, color 0.15s;
  line-height: 1.4;
}
.tiptap-content :deep(.ProseMirror p.is-editor-empty:first-child::before) {
  content: attr(data-placeholder);
  color: #9ca3af;
  pointer-events: none;
  float: left;
  height: 0;
}
.tiptap-content :deep(.ProseMirror:focus) {
  outline: none;
}
</style>
