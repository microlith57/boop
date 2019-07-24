import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["issuerField", "deviceField", "errorDetail"]

  connect() {

    // Ensure the form does not submit when the enter key is pressed in the
    // issuer field.
    this.issuerFieldTarget.addEventListener('keydown', (e) => {
      if (e.key === "Enter") {
        e.preventDefault()
        this.deviceFieldTarget.focus()
      }
    })

  }

  on_success(event) {
    let [data, status, xhr] = event.detail;

    this.element.className = "success"
    this.errorDetailTarget.innerHTML = ""
    this.clear()
  }

  on_error(event) {
    let [data, status, xhr] = event.detail;

    this.element.className = "error"
    this.errorDetailTarget.innerHTML = ""

    let json = JSON.parse(xhr.responseText)

    if (!Array.isArray(json)) {
      throw "invalid response - must be an array"
    }

    for (var err in json) {
      if (json.hasOwnProperty(err)) {
        this.errorDetailTarget.innerHTML += `<li>${json[err]}</li>`
      }
    }
    this.clear()
  }

  clear() {
    this.element.reset()
    this.issuerFieldTarget.focus()
  }
}
