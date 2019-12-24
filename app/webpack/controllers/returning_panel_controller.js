import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['form', 'field']

  connect() {
    this.reset()
  }

  success(event) {
    let [data, status, xhr] = event.detail

    this.reset()
  }

  error(event) {
    let [data, status, xhr] = event.detail

    console.log(xhr.status + ' ' + status, data)
  }

  reset() {
    this.fieldTarget.value = ''

    this.fieldTarget.focus()
  }
}
