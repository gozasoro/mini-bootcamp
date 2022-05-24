<template lang="pug">
.field
  h5.title.is-5.mb-2 コード
  .control
    textarea#editor
</template>

<script>
import ace from 'ace-builds/src-noconflict/ace'
import 'ace-builds/webpack-resolver'

export default {
  props: {
    modelValue: String,
  },
  emits: [
    'update:modelValue'
  ],
  setup(_, context) {
    const setupEditor = (mode) => {
      const setting = {
        maxLines: 200,
        minLines: 25,
        wrap: true,
        tabSize: 2,
        theme: 'ace/theme/tomorrow',
        mode: mode
      }
      const editor = ace.edit('editor', setting)

      editor.session.on('changeMode', (_, session) => {
        if (mode === 'ace/mode/javascript' && session.$worker) {
          session.$worker.send('changeOptions', [{ asi: true }])
        }
      })

      editor.session.on('change', () => {
        context.emit('update:modelValue', editor.getValue())
      })
    }
    
    return {
      setupEditor
    }
  }
}
</script>
