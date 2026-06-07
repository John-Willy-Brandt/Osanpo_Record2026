import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "container"]

  connect() {
    this.entries = []
  }

  fileSelected(event) {
    const files = Array.from(event.target.files)
    this.entries = []
    this.containerTarget.innerHTML = ""

    files.forEach((file, index) => {
      const entry = { file, rotation: 0, canvas: null, img: null }
      this.entries.push(entry)

      const slot = document.createElement("div")
      slot.className = "upload-preview-slot"

      const canvas = document.createElement("canvas")
      canvas.className = "upload-canvas"
      entry.canvas = canvas

      const actions = document.createElement("div")
      actions.className = "upload-rotate-actions"

      const ccwBtn = document.createElement("button")
      ccwBtn.type = "button"
      ccwBtn.className = "btn-rotate"
      ccwBtn.textContent = "↺ 左に回転"
      ccwBtn.addEventListener("click", () => this.rotate(index, -90))

      const cwBtn = document.createElement("button")
      cwBtn.type = "button"
      cwBtn.className = "btn-rotate"
      cwBtn.textContent = "↻ 右に回転"
      cwBtn.addEventListener("click", () => this.rotate(index, 90))

      actions.append(ccwBtn, cwBtn)
      slot.append(canvas, actions)
      this.containerTarget.appendChild(slot)

      const reader = new FileReader()
      reader.onload = (e) => {
        const img = new Image()
        img.onload = () => {
          entry.img = img
          this.drawCanvas(entry)
        }
        img.src = e.target.result
      }
      reader.readAsDataURL(file)
    })
  }

  rotate(index, degrees) {
    const entry = this.entries[index]
    if (!entry) return
    entry.rotation = (entry.rotation + degrees + 360) % 360
    this.drawCanvas(entry)
    this.updateFileInput()
  }

  drawCanvas(entry) {
    const { img, rotation, canvas } = entry
    if (!img) return
    const swapped = rotation === 90 || rotation === 270
    canvas.width  = swapped ? img.naturalHeight : img.naturalWidth
    canvas.height = swapped ? img.naturalWidth  : img.naturalHeight

    const ctx = canvas.getContext("2d")
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.save()
    ctx.translate(canvas.width / 2, canvas.height / 2)
    ctx.rotate((rotation * Math.PI) / 180)
    ctx.drawImage(img, -img.naturalWidth / 2, -img.naturalHeight / 2)
    ctx.restore()
  }

  async updateFileInput() {
    const files = await Promise.all(
      this.entries.map((entry) => {
        if (entry.rotation === 0) return Promise.resolve(entry.file)
        return new Promise((resolve) => {
          const type = entry.file.type || "image/jpeg"
          entry.canvas.toBlob(
            (blob) => resolve(new File([blob], entry.file.name, { type })),
            type
          )
        })
      })
    )

    const dt = new DataTransfer()
    files.forEach((f) => dt.items.add(f))
    this.inputTarget.files = dt.files
  }
}
