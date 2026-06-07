import { Controller } from "@hotwired/stimulus"

const MAX_PX = 1920   // resize to at most 1920px on the long side
const QUALITY = 0.82  // JPEG compression quality

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
      const entry = { filename: file.name, rotation: 0, canvas: null, img: null, blob: null }
      this.entries[index] = entry

      const slot = this.buildSlot(index)
      entry.canvas = slot.querySelector("canvas")
      this.containerTarget.appendChild(slot)

      const img = new Image()
      img.onload = () => {
        entry.img = img
        this.redraw(entry).then(() => this.syncInput())
      }
      img.src = URL.createObjectURL(file)
    })
  }

  rotate(index, degrees) {
    const entry = this.entries[index]
    if (!entry?.img) return
    entry.rotation = (entry.rotation + degrees + 360) % 360
    this.redraw(entry).then(() => this.syncInput())
  }

  // Resize to MAX_PX, apply rotation, compress to JPEG, store blob
  redraw(entry) {
    const { img, rotation, canvas } = entry
    let w = img.naturalWidth, h = img.naturalHeight

    if (w > MAX_PX || h > MAX_PX) {
      if (w >= h) { h = Math.round(h * MAX_PX / w); w = MAX_PX }
      else        { w = Math.round(w * MAX_PX / h); h = MAX_PX }
    }

    const swapped = rotation === 90 || rotation === 270
    canvas.width  = swapped ? h : w
    canvas.height = swapped ? w : h

    const ctx = canvas.getContext("2d")
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.save()
    ctx.translate(canvas.width / 2, canvas.height / 2)
    ctx.rotate((rotation * Math.PI) / 180)
    ctx.drawImage(img, -w / 2, -h / 2, w, h)
    ctx.restore()

    return new Promise((resolve) => {
      canvas.toBlob((blob) => { entry.blob = blob; resolve() }, "image/jpeg", QUALITY)
    })
  }

  // Rebuild the file input from all compressed blobs
  syncInput() {
    if (this.entries.some((e) => !e.blob)) return  // wait until all are ready
    const dt = new DataTransfer()
    this.entries.forEach((e) => dt.items.add(new File([e.blob], e.filename, { type: "image/jpeg" })))
    this.inputTarget.files = dt.files
  }

  buildSlot(index) {
    const slot = document.createElement("div")
    slot.className = "upload-preview-slot"

    const canvas = document.createElement("canvas")
    canvas.className = "upload-canvas"

    const actions = document.createElement("div")
    actions.className = "upload-rotate-actions"

    const ccw = document.createElement("button")
    ccw.type = "button"; ccw.className = "btn-rotate"; ccw.textContent = "↺ 左に回転"
    ccw.addEventListener("click", () => this.rotate(index, -90))

    const cw = document.createElement("button")
    cw.type = "button"; cw.className = "btn-rotate"; cw.textContent = "↻ 右に回転"
    cw.addEventListener("click", () => this.rotate(index, 90))

    actions.append(ccw, cw)
    slot.append(canvas, actions)
    return slot
  }
}
