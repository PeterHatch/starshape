import flatten from 'lodash.flatten'
import zip from 'lodash.zip'

import Star from './base-star'
import { calculateInnerPoints, calculateOuterPoints } from './util/math'

class LinearStar extends Star {
  constructor() {
    super('linear', ['inner-radius'])
  }

  points(innerRadius) {
    return [calculateInnerPoints(innerRadius), calculateOuterPoints()]
  }

  constructPath(innerPoints, outerPoints) {
    const points = flatten(zip(innerPoints, outerPoints))
    return `M ${points.join(' L ')} Z`
  }
}

export default new LinearStar()
