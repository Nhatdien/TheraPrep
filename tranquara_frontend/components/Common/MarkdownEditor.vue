<template>
  <section v-if="editor">
    <editor-content
      class="min-h-[40vh] rounded-2xl overflow-y-auto"
      :editor="editor" />
  </section>
</template>

<script setup>
import { useEditor, EditorContent } from "@tiptap/vue-3";
import { StarterKit } from "@tiptap/starter-kit";
import Underline from "@tiptap/extension-underline";
import { CustomParagraph } from "@/components/TiptapExtensions/CustomParagraph";

const modelValue = defineModel();
const emits = defineEmits(["onUpdate"]);
const editor = useEditor({
  editorProps: {
    attributes: {
      autocorrect: 'off',
      autocomplete: 'off',
      autocapitalize: 'off',
      spellcheck: 'false',
    },
  },
  content: modelValue.value || "",
  extensions: [StarterKit.configure({ paragraph: false }), CustomParagraph, Underline],
  onUpdate: ({ editor }) => {
    modelValue.value = editor.getHTML();
    emits("onUpdate");
  },
});

defineExpose({ editor });

onMounted(() => {
  // editor initialized
});
</script>