<template lang="pug">
.columns.is-variable.is-2.is-mobile.mb-2
  .column
    .control.mb-1
      .select.is-fullwidth
        select(v-model="selected")
          option(v-for="check in checks" :value="check.index") {{ `Check ${check.index + 1}` }}
  .column
    .control.mb-1
      button.button.is-fullwidth(@click="run" :class="isRunning ? 'is-loading' : ''")
        | コードを実行
.code-container(v-if="checks[selected]")
  code.code.stdin.mb-3(data-subtitle="標準入力") {{ checks[selected].stdin }}
  code.code.stdout(data-subtitle="期待される出力") {{ checks[selected].stdout }}
code.code.result(data-subtitle="実行結果" :class="codeResult ? codeResultClass : ''") {{ codeResult }}
</template>

<script>
import { onMounted, ref, computed } from 'vue'
import axios from 'axios'
import { setHeaders } from '../modules/set_headers'

export default {
  props: {
    checks: Array,
    id: Number,
    code: String,
  },
  setup(props) {
    onMounted(() => {
      setHeaders(axios)
    })

    const selected = ref(0)
    const isRunning = ref(false)
    const codeResult = ref('')
    const codeCorrect = ref(false)
    const codeResultClass = computed(() => codeCorrect.value ? 'success' : 'failed')

    const run = () => {
      if (props.code === '') return
      isRunning.value = true
      const data = {
        code: props.code,
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

    return {
      selected,
      run,
      isRunning,
      codeResult,
      codeCorrect,
      codeResultClass
    }
  }
}
</script>
