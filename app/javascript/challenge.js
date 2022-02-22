import { createApp } from 'vue'
import Challenge from 'Challenge.vue'

document.addEventListener('DOMContentLoaded', () => {
  const content = document.getElementById('js-challenge')
  if (content) createApp(Challenge, { id: parseInt(content.dataset.id) }).mount('#js-challenge')
})
