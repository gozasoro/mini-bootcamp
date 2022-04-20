<template lang="pug">
.modal#js-modal
  .modal-background(@click="closeModal")
  .modal-content
    .box
      textarea#model-answer
  .modal-close.is-large(aria-label="close" @click="closeModal")
</template>

<script>
import { ref } from 'vue'
import ace from 'ace-builds/src-noconflict/ace'
import 'ace-builds/webpack-resolver'

export default {
  setup() {
    const editor = ref(null)

    const setupEditor = (mode) => {
      const setting = {
        maxLines: 200,
        minLines: 25,
        wrap: true,
        tabSize: 2,
        theme: 'ace/theme/tomorrow',
        mode: mode,
        readOnly: true
      }
      editor.value = ace.edit('model-answer', setting)

      editor.value.session.on('changeMode', (_, session) => {
        if (mode === 'ace/mode/javascript' && session.$worker) {
          session.$worker.send('changeOptions', [{ asi: true }])
        }
      })
    }

    const set = (answer) => {
      editor.value.setValue(answer)
    }

    const openModal = () => {
      document.getElementById('js-modal').classList.add('is-active')
    }

    const closeModal = () => {
      document.getElementById('js-modal').classList.remove('is-active')
    }

    return {
      setupEditor,
      set,
      openModal,
      closeModal
    }
  },
}
</script>
