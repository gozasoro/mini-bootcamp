import MarkdownIt from 'markdown-it'

document.addEventListener('DOMContentLoaded', () => {
  const input = document.querySelector('.js-markdown-input')
  const preview = document.getElementById('js-markdown-preview')

  if (input) {
    const md = new MarkdownIt()

    preview.innerHTML = md.render(input.value)
    input.addEventListener('input', () => {
      preview.innerHTML = md.render(input.value)
    })
  }
})
