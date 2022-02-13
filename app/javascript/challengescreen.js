import { createApp } from 'vue'
import ChallengeScreen from 'ChallengeScreen.vue'

document.addEventListener('DOMContentLoaded', () => {
  const content = document.getElementById('js-challenge-screen')
  if (content) createApp(ChallengeScreen, { id: parseInt(content.dataset.id) }).mount('#js-challenge-screen')
})
