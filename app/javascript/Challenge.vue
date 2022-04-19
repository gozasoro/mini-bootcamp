<template lang="pug">
p.is-size-6.has-text-centered
  span.has-text-success(v-if="challenge.archivement")
    i.fas.fa-medal.mr-1
    | 達成済
  span.has-text-grey(v-else)
    | 未クリア
h1.title.is-3.has-text-centered
  | {{ challenge.title }}
.columns
  .column(style="white-space: pre-wrap")
    | {{ challenge.content }}
  .column
    .field
      label.label(for="editor") コード
      .control
        textarea#editor
    .columns.is-variable.is-2.is-mobile
      .column
        .control.mb-1
          .select.is-fullwidth
            select(v-model="selected")
              option(v-for="check in challenge.checks" :value="check.index") {{ `Check ${check.index + 1}` }}
        div(v-if="challenge.checks[selected]")
          code.stdin(data-subtitle="標準入力") {{ challenge.checks[selected].stdin }}
          code.stdout(data-subtitle="期待される出力") {{ challenge.checks[selected].stdout }}
      .column
        .control.mb-1
          button.button.is-primary.is-fullwidth(@click="run" :class="isRunning ? 'is-loading' : ''")
            | コードを実行
        .columns
          .column
            code.result(data-subtitle="実行結果" :class="codeResult ? codeResultClass : ''") {{ codeResult }}
hr
.columns.is-centered
  .column.is-12-mobile.is-4-desktop
    button.button.is-primary.mb-4.is-fullwidth(@click="judge" :class="isLoading ? 'is-loading' : ''")
      | 全てのチェックで確認する
    .columns
      .column.is-3.has-text-centered
        .is-size-7.mb-4 判定
        .is-size-5
          i.fas.fa-minus.has-text-grey-lighter(v-if="challengeSuccess === null")
          i.fas.fa-check.has-text-success(v-else-if="challengeSuccess")
          i.fas.fa-times.has-text-danger(v-else-if="!challengeSuccess")
      .column.is-3.has-text-centered
        .is-size-7.mb-3 チェック
        .is-size-5
          | {{ `${correctAnswers} / ${challenge.checks.length}` }}
      .column
        button.button.is-small.is-fullwidth.mb-2(
          v-if="next.url"
          @click="location.href(next.url)"
          :disabled="!challengeSuccess"
        )
          span {{ next.title }}
          span.icon.is-small
            i.fas.fa-arrow-right
        button.button.is-small.is-fullwidth(:disabled="!challengeSuccess" @click="openModal")
          span 模範解答
.modal#js-modal
  .modal-background(@click="closeModal")
  .modal-content
    .box
      textarea#model-answer
  .modal-close.is-large(aria-label="close" @click="closeModal")
.block
  .table-container
    table.table.is-bordered.is-relative.mx-auto
      .loading-cover(v-if="isLoading || isLoading === null")
      thead
        tr
          th
          th(v-for="check in challenge.checks") {{ `Check ${check.index + 1}` }}
      tbody
        tr
          th 判定
          td.has-text-centered(v-for="(check, index) in challenge.checks")
            i.fas.fa-minus.has-text-grey-lighter(v-if="!result[index]")
            i.fas.fa-check.has-text-success(v-else-if="result[index].success")
            i.fas.fa-times.has-text-danger(v-else-if="!result[index].success")
        tr
          th 標準入力
          td(v-for="check in challenge.checks") {{ check.stdin }}
        tr
          th 期待される出力
          td(v-for="check in challenge.checks") {{ check.stdout }}
        tr
          th 実行結果
          td(v-for="(check, index) in challenge.checks")
            span(v-if="result[index]") {{ result[index].stdout }}
hr(v-if="previous.url || next.url")
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
import { ref, reactive, computed, onMounted } from 'vue'
import axios from 'axios'
import { setHeaders } from './modules/set_headers'
import ace from 'ace-builds/src-noconflict/ace'
import 'ace-builds/webpack-resolver'

export default {
  name: 'Challenge',
  props: {
    id: {
      type: Number,
      required: true
    }
  },
  setup (props) {
    // Challenge
    const challenge = reactive({
      title: '',
      content: '',
      checks: [],
      archivement: null
    })
    const previous = reactive({
      title: null,
      url: null
    })
    const next = reactive({
      title: null,
      url: null
    })

    const getChallengeContent = async () => {
      setHeaders(axios)
      const response = await axios.get(`/api/challenges/${props.id}`).catch(error => console.log(error.response))
      const data = response.data

      challenge.title = data.title
      challenge.content = data.content
      challenge.archivement = data.archivement
      previous.title = data.previous ? data.previous.title : null
      previous.url = data.previous ? data.previous.url : null
      next.title = data.next ? data.next.title : null
      next.url = data.next ? data.next.url : null

      data.checks.forEach((check, i) => {
        const checkWithIndex = { ...check, ...{ index: i } }
        challenge.checks.push(checkWithIndex)
      })

      return data.mode
    }

    // Editor
    const modelAnswerEditor = ref(null)

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
      modelAnswerEditor.value = ace.edit('model-answer', Object.assign(setting, { readOnly: true }))

      editor.session.on('changeMode', (_, session) => {
        if (mode === 'ace/mode/javascript' && session.$worker) {
          session.$worker.send('changeOptions', [{ asi: true }])
        }
      })

      modelAnswerEditor.value.session.on('changeMode', (_, session) => {
        if (mode === 'ace/mode/javascript' && session.$worker) {
          session.$worker.send('changeOptions', [{ asi: true }])
        }
      })

      editor.session.on('change', () => {
        codeInput.value = editor.getValue()
      })
    }

    onMounted(() => {
      getChallengeContent()
        .then(mode => setupEditor(mode))
    })

    // Run and check
    const isRunning = ref(false)
    const codeInput = ref('')
    const codeResult = ref('')
    const codeCorrect = ref(false)

    const selected = ref(0)
    const codeResultClass = computed(() => codeCorrect.value ? 'success' : 'failed')

    const run = () => {
      if (codeInput.value === '') return
      isRunning.value = true
      const data = {
        code: codeInput.value,
        check: selected.value
      }
      axios.post(`/api/challenges/${props.id}/runs`, data)
        .then(response => {
          isRunning.value = false
          const exitcode = response.data.exitcode
          if (exitcode === 0 && response.data.stderr === '') {
            codeResult.value = response.data.stdout
            codeCorrect.value = response.data.success
          } else {
            codeResult.value = response.data.stderr
            codeCorrect.value = false
          }
        })
        .catch(error => console.log(error.response))
    }

    // Judge
    const isLoading = ref(null)
    const result = ref([])
    const challengeSuccess = ref(null)

    const correctAnswers = computed(() => {
      if (result.value.length === 0) {
        return '-'
      } else {
        const count = result.value.reduce(
          (correctCount, currentCheck) => {
            return currentCheck.success ? correctCount + 1 : correctCount
          }, 0)
        return count
      }
    })

    const judge = () => {
      if (codeInput.value === '') return
      isLoading.value = true
      result.value.splice(0)
      challengeSuccess.value = null
      const data = { code: codeInput.value }
      axios.post(`/api/challenges/${props.id}/judges`, data)
        .then(response => {
          challengeSuccess.value = response.data['challenge_success']
          response.data.result.forEach(check => result.value.push(check))
          isLoading.value = false
          modelAnswerEditor.value.setValue(response.data['model_answer'] || '')
        })
        .catch(error => console.log(error.response))
    }

    // Modal
    const openModal = () => {
      document.getElementById('js-modal').classList.add('is-active')
    }

    const closeModal = () => {
      document.getElementById('js-modal').classList.remove('is-active')
    }

    return {
      challenge,
      previous,
      next,
      selected,
      isRunning,
      codeInput,
      codeResult,
      codeCorrect,
      codeResultClass,
      isLoading,
      result,
      challengeSuccess,
      correctAnswers,
      run,
      judge,
      openModal,
      closeModal
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
