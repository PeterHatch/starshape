/* globals _ */

import Star from './base-star.js'
import { innerPoints, outerPoints } from './util/math.js'

class LinearStar extends Star {
  constructor() {
    super('linear', ['inner-radius'])
  }

  points(innerRadius) {
    return [innerPoints(innerRadius), outerPoints()]
  }

  constructPath(inner, outer) {
    const points = _.flatten(_.zip(inner, outer))
    return `M ${points.join(' L ')} Z`
  }
}

export default new LinearStar()
