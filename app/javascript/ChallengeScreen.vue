<template lang="pug">
h1.title.is-3.has-text-centered {{ title }}
.columns
  .column(style="white-space: pre-wrap")
    | {{ content }}
  .column
    .field
      label.label(for="editor") Myeditor
      .control
        textarea#editor
    .columns.is-variable.is-2.is-mobile
      .column
        .control.mb-1
          .select.is-fullwidth
            select(v-model="selectedCheck")
              option(v-for="check in checks" :value="check.index") {{ `Check ${check.index + 1}` }}
        div(v-if="checks[selectedCheck]")
          code.stdin(data-subtitle="標準入力") {{ checks[selectedCheck].stdin }}
          code.stdout(data-subtitle="期待される出力") {{ checks[selectedCheck].stdout }}
      .column
        .control.mb-1
          button.button.is-primary.is-fullwidth
            span.icon.is-small
              i.fas.fa-play
            span Run
        .columns
          .column
            code.result(data-subtitle="実行結果" :class="codeResultClass") {{ codeResult }}
hr
.columns
  .column.is-2
    button.button.is-primary.mb-2.is-fullwidth
      span.icon.is-small
        i.fas.fa-file-alt
      span 全て確認する
    .result.p-2.is-size-7
      .mb-2
        | result: 10/10
      a.button.is-small.is-fullwidth.mb-2(:href="next.url")
        span.icon.is-small
          i.fas.fa-arrow-right
        span {{ next.title }}
      a.button.is-small.is-fullwidth
        span.icon.is-small
          i.fas.fa-code
        span model
  .column
    .block
      .table-container
        table.table.is-bordered.is-relative.mx-auto
          .loading-cover
            .sk-wave.m-auto
              .sk-wave-rect
              .sk-wave-rect
              .sk-wave-rect
              .sk-wave-rect
              .sk-wave-rect
          thead
            tr
              th
              th(v-for="check in checks") {{ `Check ${check.index + 1}` }}
          tbody
            tr
              th 判定
              td.has-text-centered.has-text-grey-lighter(v-for="check in checks")
                i.fas.fa-minus
            tr
              th 標準入力
              td(v-for="check in checks") {{ check.stdin }}
            tr
              th 期待される出力
              td(v-for="check in checks") {{ check.stdout }}
            tr
              th 実行結果
              td(v-for="check in checks") {{ check.codeResult }}
hr
nav.level
  .level-left
    .level-item(v-if="previous.url")
      a.button.is-light.is-small(:href="previous.url")
        span.icon.is-small
          i.fas.fa-caret-left
        span {{ previous.title }}
  .level-right
    .level-item(v-if="next.url")
      a.button.is-light.is-small(:href="next.url")
        span {{ next.title }}
        span.icon.is-small
          i.fas.fa-caret-right
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { setHeaders } from './modules/set_headers'
import ace from 'ace-builds/src-noconflict/ace'
import 'ace-builds/webpack-resolver'

export default {
  name: 'ChallengeScreen',
  props: {
    id: {
      type: Number,
      required: true
    }
  },
  setup (props) {
    const checks = ref([])
    const selectedCheck = ref(0)
    const title = ref('')
    const content = ref('')
    const codeInput = ref('mycode')
    const codeResult = ref(``)
    const codeCorrect = ref(false)

    const previous = ref({})
    const next = ref({})

    onMounted(() => {
      getChallengeContent()
        .then(mode => {
          setupEditor(mode)
        })
    })

    const getChallengeContent = async () => {
      setHeaders(axios)
      const response = await axios.get(`/api/challenges/${props.id}`).catch(error => { console.log(error.response) })

      title.value = response.data.title
      console.log(response.data)
      content.value = response.data.content
      previous.value.title = response.data.previous ? response.data.previous.title : null
      previous.value.url = response.data.previous ? response.data.previous.url : null
      next.value.title = response.data.next ? response.data.next.title : null
      next.value.url = response.data.next ? response.data.next.url : null

      response.data.checks.forEach((check, i) => {
        const checkWithIndex = { ...check, ...{ index: i } }
        checks.value.push(checkWithIndex)
      })

      return response.data.mode
    }

    const setupEditor = (mode) => {
      const editor = ace.edit('editor', {
        maxLines: 200,
        minLines: 25,
        wrap: true,
        tabSize: 2,
        theme: 'ace/theme/tomorrow',
        mode: mode
      })

      editor.session.on('changeMode', (_, session) => {
        if (mode === 'ace/mode/javascript' && session.$worker) {
          session.$worker.send('changeOptions', [{ asi: true }])
        }
      })

      editor.session.on('change', () => {
        codeInput.value = editor.getValue()
      })
    }

    const codeResultClass = computed(() => {
      let className = ''
      switch (codeCorrect.value) {
        case true:
          className = 'success'
          break
        case false:
          className = 'failed'
          break
      }
      return className
    })

    return {
      checks,
      title,
      content,
      codeInput,
      codeResult,
      selectedCheck,
      codeCorrect,
      codeResultClass,
      previous,
      next
    }
  }
}
</script>

<style scoped>

  table {
    white-space: pre;
  }

  table th {
    font-weight: normal;
    font-size: 0.75rem;
    vertical-align: middle;
  }
  .loading-cover {
    display: flex;
    position: absolute;
    width: calc(100% + 2px);
    height: calc(100% + 2px);
    z-index: 10;
    top: -1px;
    left: -1px;
    background: #ffffffcc;
  }
</style>
