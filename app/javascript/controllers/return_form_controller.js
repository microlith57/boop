import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["deviceField", "errorDetail"]

  connect() {
  }

  on_success(event) {
    let [data, status, xhr] = event.detail;

    this.element.className = "success"
    this.errorDetailTarget.innerHTML = ""
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
  }
}
