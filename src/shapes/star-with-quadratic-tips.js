import zip from 'lodash.zip'

import InnerAndIntermediateStar from './base-inner-and-intermediate-star'
import linearStar from './linear-star'
import quadraticStar from './quadratic-star'


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

  constructPath(innerPoints, intermediatePoints1, intermediatePoints2, outerPoints) {
    const points = zip(innerPoints, intermediatePoints1, outerPoints, intermediatePoints2)

    const sectionStrings = points.map(([inner, intermediate1, outer, intermediate2]) =>
      `${inner} L ${intermediate1} Q ${outer} ${intermediate2}`)
    return `M ${sectionStrings.join(' L ')} Z`
  }
}

export default new StarWithQuadraticTips()
