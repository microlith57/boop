import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [
    'nameField',
    'codeField',
    'emailField',
    'defaultEmailSuffix'
  ]

  connect() {
  }

  // TODO: Refactor
  nameEdited() {
    const value = this.nameFieldTarget.value.toLowerCase().replace(/[^a-z]/g, '')
    this.codeFieldTarget.defaultValue = value
    this.emailFieldTarget.defaultValue = (this.codeFieldTarget.value || value) + this.emailSuffix()
  }

  // TODO: Refactor
  codeEdited() {
    const value = this.codeFieldTarget.value.toLowerCase().replace(/[^a-z]/g, '')
    this.emailFieldTarget.defaultValue = value + this.emailSuffix()
  }
  
  // Obtain the email suffix from the form.
  emailSuffix() {
    return this.defaultEmailSuffixTarget.value
  }
}
