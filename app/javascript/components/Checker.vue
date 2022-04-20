<template lang="pug">
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
          | {{ `${correctAnswers} / ${checks.length}` }}
      .column
        button.button.is-small.is-fullwidth.mb-2(
          v-if="nextChallenge.url"
          @click="location.href(nextChallenge.url)"
          :disabled="!challengeSuccess"
        )
          span {{ nextChallenge.title }}
          span.icon.is-small
            i.fas.fa-arrow-right
        button.button.is-small.is-fullwidth(:disabled="!challengeSuccess" @click="$emit('open-modal')")
          span 模範解答
.block
  .table-container
    table.table.is-bordered.is-relative.mx-auto
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
