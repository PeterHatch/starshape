/* globals _ */

import InnerAndIntermediateStar from './base-inner-and-intermediate-star.js'
import linearStar from './linear-star.js'
import quadraticStar from './quadratic-star.js'


class StarWithQuadraticTips extends InnerAndIntermediateStar {
  constructor() {
    super('quadratic', ['inner-radius', 'straight-percentage'])
  }

  path(innerRadius, straightPercentage) {
    if (straightPercentage === '100') {
      return linearStar.path(innerRadius)
    }
    if (straightPercentage === '0') {
      return quadraticStar.path(innerRadius)
    }

    return super.path(innerRadius, straightPercentage)
  }

  constructPath(inner, intermediate1, intermediate2, outer) {
    const points = _.zip(inner, intermediate1, outer, intermediate2)

    const sectionStrings = points.map(([inner, intermediate1, outer, intermediate2]) =>
        `${inner} L ${intermediate1} Q ${outer} ${intermediate2}`)
    return `M ${sectionStrings.join(' L ')} Z`
  }
}

export default new StarWithQuadraticTips()
