/* globals _ */

import Star from './base-star.js'
import { outerPoints, innerPoints, calculateIntermediatePoints, calculateIntermediatePointsComingAndGoing } from './util/math.js'
import linearStar from './linear-star.js'
import cubicStar from './cubic-star.js'

class StarWithCubicTips extends Star {
  constructor() {
    super('cubic', ['inner-radius', 'straight-percentage', 'control-percentage'])
  }

  path(innerRadius, straightPercentage, controlPercentage) {
    if (straightPercentage === '100') {
      return linearStar.path(innerRadius)
    }
    if (straightPercentage === '0') {
      return cubicStar.path(innerRadius, controlPercentage)
    }

    return super.path(innerRadius, straightPercentage, controlPercentage)
  }

  points(innerRadius, straightPercentage, controlPercentage) {
    const outer = outerPoints()
    const inner = innerPoints(innerRadius)
    const [intermediate1, intermediate2] = calculateIntermediatePointsComingAndGoing(inner, outer, straightPercentage)
    const [control1, control2] = calculateIntermediatePoints(intermediate1, intermediate2, outer, controlPercentage)

    return [inner, intermediate1, intermediate2, control1, control2]
  }

  constructPath(inner, intermediate1, intermediate2, control1, control2) {
    const points = _.zip(inner, intermediate1, control1, control2, intermediate2)

    const sectionStrings = points.map(([inner, intermediate1, control1, control2, intermediate2]) =>
        `${inner} L ${intermediate1} C ${control1} ${control2} ${intermediate2}`)
    return `M ${sectionStrings.join(' L ')} Z`
  }
}

export default new StarWithCubicTips()
