import zip from 'lodash.zip'

import InnerAndIntermediateStar from './base-inner-and-intermediate-star.js'
import { calculateRadius } from './util/math.js'
import linearStar from './linear-star.js'

class StarWithCircularTips extends InnerAndIntermediateStar {
  constructor() {
    super('circular', ['inner-radius', 'straight-percentage'])
  }

  path(innerRadius, straightPercentage) {
    if (straightPercentage === '100') {
      return linearStar.path(innerRadius)
    }

    return super.path(innerRadius, straightPercentage)
  }

  points(innerRadius, straightPercentage) {
    const [inner, intermediate1, intermediate2, outer] = super.points(innerRadius, straightPercentage)
    const radius = calculateRadius(intermediate1[0], outer[0], intermediate2[0])

    return [inner, intermediate1, intermediate2, radius]
  }

  constructPath(innerPoints, intermediatePoints1, intermediatePoints2, radius) {
    const points = zip(innerPoints, intermediatePoints1, intermediatePoints2)

    const sectionStrings = points.map(([inner, intermediate1, intermediate2]) =>
        `${inner} L ${intermediate1} A ${radius} ${radius} 0 0 1 ${intermediate2}`)
    return `M ${sectionStrings.join(' L ')} Z`
  }
}

export default new StarWithCircularTips()
