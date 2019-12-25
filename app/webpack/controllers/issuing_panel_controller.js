import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = [
    'issuerForm',
    'deviceForm',
    'summaryPane',
    'issuerField',
    'deviceField',
    'submit',
    'status',
  ]

  inProgress = false

  connect() {
    this.reset(true)
  }

  issuer_success(event) {
    let [data, status, xhr] = event.detail

    this.summaryPaneTarget.innerHTML = data
    this.summaryPaneTarget.classList.remove('hidden')

    this.deviceFieldTarget.focus()
    this.submitTarget.disabled = false
    this.inProgress = true

    this.statusTarget.innerText = 'Found Issuer'
    this.statusTarget.classList.remove('error')
  }

  issuer_error(event) {
    let [data, status, xhr] = event.detail

    this.statusTarget.innerText = `${xhr.status} ${status}: ${data}`
    this.statusTarget.classList.add('error')
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

    this.statusTarget.innerText = `${xhr.status} ${status}: ${data}`
    this.statusTarget.classList.add('error')
  }

  reset(initial = false) {
    this.inProgress = false

    this.submitTarget.disabled = true

    this.summaryPaneTarget.innerHTML = ''
    this.summaryPaneTarget.classList.add('hidden')

    this.issuerFieldTarget.value = ''
    this.deviceFieldTarget.value = ''

    if (!initial) {
      this.issuerFieldTarget.focus()
      this.statusTarget.innerText = 'Success'
      this.statusTarget.classList.remove('error')
    }
  }
}
