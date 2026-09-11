import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]

  backdropClose(event) {
    if (event.target === this.element) {
      this.close()
    }
  }

  close() {
    const dialog = this.dialogTarget

    if (dialog.classList.contains("animate-fade-out")) return

    dialog.classList.add("animate-fade-out")
    dialog.addEventListener("animationend", () => this.clearModal(), { once: true })
  }

  clearModal() {
    const frame = document.getElementById("task_modal")
    frame?.replaceChildren()
  }
}