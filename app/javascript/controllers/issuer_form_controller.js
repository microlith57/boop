import { Controller } from "stimulus";

// BUG: [add text to name field] <tab> [add text to code field] <tab> doesn't complete 3rd field on either <tab>
export default class extends Controller {
  static targets = ['nameField', 'codeField', 'emailField']
  static emailSuffix = '@spotswoodcollege.school.nz'

  connect() {
  }

  // TODO: Configurable email suffix
  nameEdited() {
    const value = this.nameFieldTarget.value.toLowerCase().replace(/[^a-z]/g, '')
    this.codeFieldTarget.defaultValue = value
    this.emailFieldTarget.defaultValue = (this.codeFieldTarget.value || value) + emailSuffix
  }

  // TODO: Configurable email suffix
  codeEdited() {
    const value = this.codeFieldTarget.value.toLowerCase().replace(/[^a-z]/g, '')
    this.emailFieldTarget.defaultValue = value + emailSuffix
  }

  setDefaults() {
    if (this.codeFieldTarget.value == '') {
      this.codeFieldTarget.value = this.codeFieldTarget.defaultValue
    }
    if (this.emailFieldTarget.value == '') {
      this.emailFieldTarget.value = this.codeFieldTarget.defaultValue
    }
  }
}
