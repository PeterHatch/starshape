/* globals $ */

import { updateUrlQuery } from '../uri.js'
import { showControls, controlVals } from '../controls.js'

let currentStar = null

export default class Star {
  constructor(name, controls) {
    this.name = name
    this.controls = controls
    this.use = () => {
      currentStar = this
      showControls(...this.controls)
      updateUrlQuery('s', this.name)
      this.refreshPath()
    }
  }

  refreshPath() {
    const pathString = this.path(...controlVals(...this.controls))
    $('#star').attr('d', pathString)
  }

  path(...inputs) {
    const points = this.points(...inputs)
    return this.constructPath(...points)
  }
}

export function updateStarPath() {
  currentStar.refreshPath()
}
