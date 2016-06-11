/* globals _ */

import Star from './base-star.js'
import { innerPoints, outerPoints } from '../star.js'

class QuadraticStar extends Star {
  constructor() {
    super(null, ['inner-radius'])
  }

  points(innerRadius) {
    return [innerPoints(innerRadius), outerPoints()]
  }

  constructPath(inner, outer) {
    const first = inner[0]
    inner.push(inner.shift())
    const points = _.zip(outer, inner)

    const sectionStrings = points.map(([outer, inner]) =>
        `Q ${outer} ${inner}`)

    return `M ${first} ${sectionStrings.join(' ')} Z`
  }
}

export default new QuadraticStar()
