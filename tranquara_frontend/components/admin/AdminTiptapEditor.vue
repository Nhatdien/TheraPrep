<template>
  <div class="tiptap-wrapper border border-gray-200 dark:border-gray-700 rounded-lg overflow-hidden focus-within:ring-2 focus-within:ring-primary-500 focus-within:border-primary-500 transition-all">
    <!-- Toolbar -->
    <div class="flex items-center gap-0.5 px-2 py-1.5 border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-800/60 flex-wrap">
      <button
        v-for="btn in toolbarButtons" :key="btn.label"
        type="button"
        @click="btn.action()"
        :class="btn.isActive?.() ? 'bg-gray-200 dark:bg-gray-600 text-gray-900 dark:text-white' : 'text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-white'"
        class="px-2 py-1 rounded text-xs font-medium transition-colors"
        :title="btn.label"
      >
        {{ btn.label }}
      </button>
      <div class="w-px h-4 bg-gray-200 dark:bg-gray-600 mx-1" />
      <button
        type="button"
        @click="editor?.chain().focus().clearNodes().unsetAllMarks().run()"
        class="px-2 py-1 rounded text-xs text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 hover:text-gray-700 dark:hover:text-gray-200 transition-colors"
        title="Clear formatting"
      >Clear</button>
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

const editor = useEditor({
  content: props.modelValue || '',
  extensions: [StarterKit],
  editorProps: {
    attributes: {
      class: 'prose prose-sm dark:prose-invert max-w-none outline-none min-h-[90px] px-3 py-2.5',
    },
  },
  onUpdate: ({ editor }) => {
    const html = editor.getHTML();
    emit('update:modelValue', html === '<p></p>' ? '' : html);
  },
});

watch(() => props.modelValue, (val) => {
  if (!editor.value) return;
  const current = editor.value.getHTML();
  const incoming = val || '';
  if (incoming !== current && !(incoming === '' && current === '<p></p>')) {
    editor.value.commands.setContent(incoming, false);
  }
});

onBeforeUnmount(() => editor.value?.destroy());

const toolbarButtons = computed(() => [
  { label: 'B', action: () => editor.value?.chain().focus().toggleBold().run(), isActive: () => !!editor.value?.isActive('bold') },
  { label: 'I', action: () => editor.value?.chain().focus().toggleItalic().run(), isActive: () => !!editor.value?.isActive('italic') },
  { label: 'S', action: () => editor.value?.chain().focus().toggleStrike().run(), isActive: () => !!editor.value?.isActive('strike') },
  { label: 'H2', action: () => editor.value?.chain().focus().toggleHeading({ level: 2 }).run(), isActive: () => !!editor.value?.isActive('heading', { level: 2 }) },
  { label: 'H3', action: () => editor.value?.chain().focus().toggleHeading({ level: 3 }).run(), isActive: () => !!editor.value?.isActive('heading', { level: 3 }) },
  { label: '• List', action: () => editor.value?.chain().focus().toggleBulletList().run(), isActive: () => !!editor.value?.isActive('bulletList') },
  { label: '1. List', action: () => editor.value?.chain().focus().toggleOrderedList().run(), isActive: () => !!editor.value?.isActive('orderedList') },
  { label: '❝', action: () => editor.value?.chain().focus().toggleBlockquote().run(), isActive: () => !!editor.value?.isActive('blockquote') },
]);
</script>

<style scoped>
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
