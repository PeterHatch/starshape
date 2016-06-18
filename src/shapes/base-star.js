import { updateUrlQuery } from '../uri.js'
import { showSliders, readSliders } from '../sliders.js'

let currentStar = null

export default class Star {
  constructor(name, sliderNames) {
    this.name = name
    this.sliderNames = sliderNames
    this.use = () => {
      currentStar = this
      showSliders(...this.sliderNames)
      updateUrlQuery('s', this.name)
      this.refreshPath()
    }
  }

  refreshPath() {
    const pathString = this.path(...readSliders(...this.sliderNames))
    document.getElementById('star').setAttribute('d', pathString)
  }

  path(...inputs) {
    const points = this.points(...inputs)
    return this.constructPath(...points)
  }
}

export function updateStarPath() {
  currentStar.refreshPath()
}
