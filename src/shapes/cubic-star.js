import _ from 'underscore'

import InnerAndIntermediateStar from './base-inner-and-intermediate-star.js'

class CubicStar extends InnerAndIntermediateStar {
  constructor() {
    super(null, ['inner-radius', 'control-percentage'])
  }

  points(innerRadius, controlPercentage) {
    const [inner, control1, control2, _outer] = super.points(innerRadius, controlPercentage)
    return [inner, control1, control2]
  }

  constructPath(innerPoints, controlPoints1, controlPoints2) {
    const first = innerPoints[0]
    innerPoints.push(innerPoints.shift())
    const points = _.zip(controlPoints1, controlPoints2, innerPoints)

    const sectionStrings = points.map(([control1, control2, inner]) =>
        `C ${control1} ${control2} ${inner}`)
    return `M ${first} ${sectionStrings.join(' ')} Z`
  }
}

export default new CubicStar()
