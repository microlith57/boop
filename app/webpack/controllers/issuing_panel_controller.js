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

  // [from, to]; ensure application.scss default colours match these the 'to'
  // colors here to avoid 'popping'!
  anim_keyframes = {
    success: { background: ['#2bff79', '#d2fbe1'] },
    error: { background: ['#cc4b37', '#a67a74'] },
  }
  anim_options = { duration: 1300, easing: 'ease' }

  inProgress = false

  connect() {
    this.reset(true)
  }

  issuer_success(event) {
    let [data, status, xhr] = event.detail

    this.summaryPaneTarget.innerHTML = data.body.innerHTML
    this.summaryPaneTarget.classList.remove('hidden')

    this.deviceFieldTarget.focus()
    this.submitTarget.disabled = false
    this.inProgress = true

    this.statusTarget.innerText = 'Found Issuer'
    this.statusTarget.classList.remove('error')

    this.statusTarget.animate(this.anim_keyframes.success, this.anim_options)
  }

  issuer_error(event) {
    let [data, status, xhr] = event.detail

    this.statusTarget.innerText = `${xhr.status} ${status}: ${data}`
    this.statusTarget.classList.add('error')

    this.issuerFieldTarget.select()

    this.statusTarget.animate(this.anim_keyframes.error, this.anim_options)
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

    this.statusTarget.animate(this.anim_keyframes.success, this.anim_options)
  }

  device_error(event) {
    let [data, status, xhr] = event.detail

    this.statusTarget.innerText = `${xhr.status} ${status}: ${data}`
    this.statusTarget.classList.add('error')

    this.deviceFieldTarget.select()

    this.statusTarget.animate(this.anim_keyframes.error, this.anim_options)
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
