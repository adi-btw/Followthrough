import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault()
    const html = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", String(Date.now()))
    this.containerTarget.insertAdjacentHTML("beforeend", html)
  }

  remove(event) {
    event.preventDefault()
    const row = event.target.closest(".recommendation-row")
    if (!row) return

    row.querySelectorAll("[required]").forEach((input) => {
      input.required = false
    })

    const id = row.querySelector("input[name*='[id]']")
    if (id && id.value) {
      const destroy = row.querySelector("input[name*='[_destroy]']")
      if (destroy) destroy.value = "1"
      row.hidden = true
    } else {
      row.remove()
    }
  }
}
