import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['form', 'field', 'status']

  connect() {
    this.reset(true)
  }

  success(event) {
    let [data, status, xhr] = event.detail

    this.reset()
  }

  error(event) {
    let [data, status, xhr] = event.detail

    this.statusTarget.innerText = `${xhr.status} ${status}: ${data}`
    this.statusTarget.classList.add('error')
  }

  reset(initial = false) {
    this.fieldTarget.value = ''

    if (!initial) {
      this.fieldTarget.focus()
      this.statusTarget.innerText = 'Success'
      this.statusTarget.classList.remove('error')
    }
  }
}
