import Sortable from 'sortablejs'
import axios from 'axios'
import { setHeaders } from './modules/set_headers'

document.addEventListener('DOMContentLoaded', () => {
  const items = document.getElementById('js-sortable')

  if (items) {
    setHeaders(axios)

    Sortable.create(items, {
      draggable: '.item',
      onUpdate: (evt) => {
        const id = evt.item.dataset.id
        const model = items.dataset.model
        let data = {}
        if (model === 'categories') {
          data = { category: { row_order_position: evt.newIndex } }
        } else if (model === 'challenges') {
          data = { challenge: { row_order_position: evt.newIndex } }
        }
        axios.patch(`/api/${model}/${id}`, data)
          .catch(error => {
            console.log(error.response.data.messages)
          })
      }
    })
  }
})
