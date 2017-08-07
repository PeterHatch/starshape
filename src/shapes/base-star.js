import { updateUrlQuery } from '../url'
import { showSliders, readSliders } from '../sliders'

let currentStar = null

export default class Star {
  constructor(name, sliderNames) {
    this.name = name
    this.sliderNames = sliderNames
    this.use = () => {
      currentStar = this
      showSliders(...this.sliderNames)
      updateUrlQuery('s', this.name) // This needs to be after showSliders, as that updates the options, and this does the actual URL update
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
