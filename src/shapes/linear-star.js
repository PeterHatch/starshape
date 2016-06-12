import _ from 'underscore'

import Star from './base-star.js'
import { calculateInnerPoints, calculateOuterPoints } from './util/math.js'

class LinearStar extends Star {
  constructor() {
    super('linear', ['inner-radius'])
  }

  points(innerRadius) {
    return [calculateInnerPoints(innerRadius), calculateOuterPoints()]
  }

  constructPath(innerPoints, outerPoints) {
    const points = _.flatten(_.zip(innerPoints, outerPoints))
    return `M ${points.join(' L ')} Z`
  }
}

export default new LinearStar()
