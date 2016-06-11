import Star from './base-star.js'
import { calculateOuterPoints, calculateInnerPoints, calculateIntermediatePointsComingAndGoing } from './util/math.js'

export default class InnerAndIntermediateStar extends Star {
  points(innerRadius, percentage) {
    const outer = calculateOuterPoints()
    const inner = calculateInnerPoints(innerRadius)
    const [intermediate1, intermediate2] = calculateIntermediatePointsComingAndGoing(inner, outer, percentage)

    return [inner, intermediate1, intermediate2, outer]
  }
}
