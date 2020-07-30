import { Controller } from 'stimulus'

export default class extends Controller {
  upload(event) {
    this.element.submit()
  }
}
