/* globals _ */

import InnerAndIntermediateStar from './base-inner-and-intermediate-star.js'

class CubicStar extends InnerAndIntermediateStar {
  constructor() {
    super(null, ['inner-radius', 'control-percentage'])
  }

  points(innerRadius, controlPercentage) {
    const [inner, control1, control2, _outer] = super.points(innerRadius, controlPercentage)
    return [inner, control1, control2]
  }

  constructPath(inner, control1, control2) {
    const first = inner[0]
    inner.push(inner.shift())
    const points = _.zip(control1, control2, inner)

    const sectionStrings = points.map(([control1, control2, inner]) =>
        `C ${control1} ${control2} ${inner}`)
    return `M ${first} ${sectionStrings.join(' ')} Z`
  }
}

export default new CubicStar()
