import Star from './base-star'
import { calculateOuterPoints, calculateInnerPoints, calculateIntermediatePointsComingAndGoing } from './util/math'

export default class InnerAndIntermediateStar extends Star {
  points(innerRadius, percentage) {
    const outer = calculateOuterPoints()
    const inner = calculateInnerPoints(innerRadius)
    const [intermediate1, intermediate2] = calculateIntermediatePointsComingAndGoing(inner, outer, percentage)

    return [inner, intermediate1, intermediate2, outer]
  }
}
