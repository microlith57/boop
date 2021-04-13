import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['nameField', 'codeField']

  connect() {}

  nameEdited() {
    this.codeFieldTarget.defaultValue = this.nameFieldTarget.value
      .trim()
      .toLowerCase()
      .replace(/[^a-z0-9\-_ ]/g, '')
      .replace(/[ ]/g, '-')
  }
}
