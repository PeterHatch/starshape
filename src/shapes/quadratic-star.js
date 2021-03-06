import zip from 'lodash.zip'

import Star from './base-star'
import { calculateInnerPoints, calculateOuterPoints } from './util/math'

class QuadraticStar extends Star {
  constructor() {
    super(null, ['inner-radius'])
  }

  points(innerRadius) {
    return [calculateInnerPoints(innerRadius), calculateOuterPoints()]
  }

  constructPath(innerPoints, outerPoints) {
    const first = innerPoints[0]
    innerPoints.push(innerPoints.shift())
    const points = zip(outerPoints, innerPoints)

    const sectionStrings = points.map(([outer, inner]) =>
      `Q ${outer} ${inner}`)

    return `M ${first} ${sectionStrings.join(' ')} Z`
  }
}

export default new QuadraticStar()
