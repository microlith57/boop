import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [
    'issuerForm',
    'deviceForm',
    'summaryPane',
    'issuerField',
    'deviceField',
    'submit',
  ]

  inProgress = false

  connect() {
    this.reset()
  }

  issuer_success(event) {
    let [data, status, xhr] = event.detail

    this.summaryPaneTarget.innerHTML = data
    this.summaryPaneTarget.classList.remove('hidden')

    this.deviceFieldTarget.focus()
    this.submitTarget.disabled = false
    this.inProgress = true
  }

  issuer_error(event) {
    let [data, status, xhr] = event.detail

    console.log(xhr.status + ' ' + status, data)
  }

  issuer_edited(event) {
    if (this.inProgress) {
      this.submitTarget.disabled = true

      this.summaryPaneTarget.innerHTML = ''
      this.summaryPaneTarget.classList.add('hidden')
    }
  }

  device_success(event) {
    let [data, status, xhr] = event.detail

    this.reset()
  }

  device_error(event) {
    let [data, status, xhr] = event.detail

    console.log(xhr.status + ' ' + status, data)
  }

  reset() {
    this.inProgress = false

    this.submitTarget.disabled = true

    this.summaryPaneTarget.innerHTML = ''
    this.summaryPaneTarget.classList.add('hidden')

    this.issuerFieldTarget.value = ''
    this.deviceFieldTarget.value = ''

    this.issuerFieldTarget.focus()
  }
}
