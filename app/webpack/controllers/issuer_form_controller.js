import { Controller } from 'stimulus'

export default class extends Controller {
  static targets = ['nameField', 'codeField', 'emailField']

  connect() {}

  // TODO: Refactor
  nameEdited() {
    const value = this.nameFieldTarget.value
      .toLowerCase()
      .replace(/[^a-z]/g, '')

    this.codeFieldTarget.defaultValue = value
    this.emailFieldTarget.defaultValue =
      (this.codeFieldTarget.value || value) + this.data.get('emailSuffix')
  }

  // TODO: Refactor
  codeEdited() {
    const value = this.codeFieldTarget.value
      .toLowerCase()
      .replace(/[^a-z]/g, '')

    this.emailFieldTarget.defaultValue = value + this.data.get('emailSuffix')
  }
}
