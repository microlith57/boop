import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['form', 'field', 'status']

  // [from, to]; ensure application.scss default colours match these the 'to'
  // colors here to avoid 'popping'!
  anim_keyframes = {
    success: { background: ['#2bff79', '#d2fbe1'] },
    error: { background: ['#cc4b37', '#a67a74'] },
  }
  anim_options = { duration: 1300, easing: 'ease' }

  connect() {
    this.fieldTarget.value = ''
  }

  success(event) {
    let [data, status, xhr] = event.detail

    this.fieldTarget.value = ''

    this.fieldTarget.focus()
    this.statusTarget.innerText = data
    this.statusTarget.classList.remove('error')

    this.statusTarget.animate(this.anim_keyframes.success, this.anim_options)
  }

  error(event) {
    let [data, status, xhr] = event.detail

    const first_line = data.split('\n')[0]

    this.statusTarget.innerText = `${xhr.status} ${status}: ${first_line}`
    this.statusTarget.classList.add('error')

    this.statusTarget.animate(this.anim_keyframes.error, this.anim_options)

    this.fieldTarget.select()
  }
}
