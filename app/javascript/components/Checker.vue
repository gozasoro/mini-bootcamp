<template lang="pug">
.columns.is-centered
  .column.is-12-mobile.is-4-desktop
    button.button.is-size-5.is-primary.mb-4.is-fullwidth(@click="judge" :class="isLoading ? 'is-loading' : ''")
      | 全てのCheckで確認する
    .columns.is-mobile
      .column.has-text-centered
        span.mr-2.has-text-weight-bold 実行結果: 判定
        i.fas.fa-minus.has-text-grey-lighter(v-if="challengeSuccess === null")
        i.fas.fa-check.has-text-success(v-else-if="challengeSuccess")
        i.fas.fa-times.has-text-danger(v-else-if="!challengeSuccess")
        span.ml-2
          | {{ `(${correctAnswers}/${checks.length})` }}
      .column
        button.button.is-small.is-fullwidth(:disabled="!challengeSuccess" @click="$emit('open-modal')")
          span 模範解答を見る
.block
  .table-container
    table.table.is-bordered.is-relative.mx-auto.result-table
      .loading-cover(v-if="isLoading || isLoading === null")
      thead
        tr
          th
          th(v-for="check in checks") {{ `Check ${check.index + 1}` }}
      tbody
        tr
          th 判定
          td.has-text-centered(v-for="(check, index) in checks")
            i.fas.fa-minus.has-text-grey-lighter(v-if="!result[index]")
            i.fas.fa-check.has-text-success(v-else-if="result[index].success")
            i.fas.fa-times.has-text-danger(v-else-if="!result[index].success")
        tr
          th 標準入力
          td(v-for="check in checks") {{ check.stdin }}
        tr
          th 期待される出力
          td(v-for="check in checks") {{ check.stdout }}
        tr
          th 実行結果
          td(v-for="(check, index) in checks")
            span(v-if="result[index]") {{ result[index].stdout }}
</template>

<script>
import { onMounted, ref, computed } from 'vue'
import axios from 'axios'
import { setHeaders } from '../modules/set_headers'

export default {
  props: {
    id: Number,
    checks: Array,
    code: String,
    nextChallenge: Object
  },
  emits: [
    'set-answer',
    'open-modal'
  ],
  setup(props, context) {
    onMounted(() => {
      setHeaders(axios)
    })

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
      if (props.code === '') return
      isLoading.value = true
      result.value.splice(0)
      challengeSuccess.value = null
      const data = { code: props.code }
      axios.post(`/api/challenges/${props.id}/judges`, data)
        .then(response => {
          challengeSuccess.value = response.data['challenge_success']
          response.data.result.forEach(check => result.value.push(check))
          isLoading.value = false
          context.emit('set-answer', response.data['model_answer'] || '')
        })
        .catch(error => console.log(error.response))
    }

    return {
      isLoading,
      result,
      challengeSuccess,
      correctAnswers,
      judge
    }
  }
}
</script>
