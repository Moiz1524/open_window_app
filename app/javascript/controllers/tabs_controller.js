import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    const hash = window.location.hash.slice(1)
    const index = this.tabTargets.findIndex(t => t.dataset.tabsKey === hash)
    this.activate(index >= 0 ? index : 0)
  }

  show(event) {
    const index = this.tabTargets.indexOf(event.currentTarget)
    history.replaceState(null, "", `#${event.currentTarget.dataset.tabsKey}`)
    this.activate(index)
  }

  activate(index) {
    this.tabTargets.forEach((tab, i) => {
      const active = i === index
      tab.setAttribute("aria-selected", active)
      tab.classList.toggle("border-indigo-600", active)
      tab.classList.toggle("text-indigo-600", active)
      tab.classList.toggle("border-transparent", !active)
      tab.classList.toggle("text-slate-500", !active)
      tab.classList.toggle("hover:text-slate-700", !active)
      tab.classList.toggle("hover:border-slate-300", !active)
    })
    this.panelTargets.forEach((panel, i) => {
      panel.hidden = i !== index
    })
  }
}
