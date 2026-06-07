import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "canvas", "preview"]

  connect() {
    this.rotation = 0
    this.originalImage = null
  }

  fileSelected(event) {
    const file = event.target.files[0]
    if (!file) {
      this.previewTarget.style.display = "none"
      this.rotation = 0
      this.originalImage = null
      return
    }

    const reader = new FileReader()
    reader.onload = (e) => {
      const img = new Image()
      img.onload = () => {
        this.originalImage = img
        this.rotation = 0
        this.drawCanvas()
        this.previewTarget.style.display = "block"
      }
      img.src = e.target.result
    }
    reader.readAsDataURL(file)
  }

  rotateCw() {
    this.rotation = (this.rotation + 90) % 360
    this.drawCanvas()
    this.updateFileInput()
  }

  rotateCcw() {
    this.rotation = (this.rotation - 90 + 360) % 360
    this.drawCanvas()
    this.updateFileInput()
  }

  drawCanvas() {
    const img = this.originalImage
    const canvas = this.canvasTarget
    const r = this.rotation
    const swapped = r === 90 || r === 270

    canvas.width  = swapped ? img.naturalHeight : img.naturalWidth
    canvas.height = swapped ? img.naturalWidth  : img.naturalHeight

    const ctx = canvas.getContext("2d")
    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.save()
    ctx.translate(canvas.width / 2, canvas.height / 2)
    ctx.rotate((r * Math.PI) / 180)
    ctx.drawImage(img, -img.naturalWidth / 2, -img.naturalHeight / 2)
    ctx.restore()
  }

  updateFileInput() {
    const input = this.inputTarget
    if (!input.files[0]) return
    const filename    = input.files[0].name
    const contentType = input.files[0].type || "image/jpeg"

    this.canvasTarget.toBlob((blob) => {
      const file = new File([blob], filename, { type: contentType })
      const dt = new DataTransfer()
      dt.items.add(file)
      input.files = dt.files
    }, contentType)
  }
}
