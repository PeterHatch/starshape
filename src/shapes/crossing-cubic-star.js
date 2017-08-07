import zip from 'lodash.zip'

import Star from './base-star'
import { calculateOuterPoints, getOuterAngles, polarToCartesian, addPoints } from './util/math'

class CrossingCubicStar extends Star {
  constructor() {
    super('crossingcubic', ['control-angle', 'control-distance'])
  }

  points(controlAngle, controlDistance) {
    const outer = calculateOuterPoints()

    const halfAngle = (controlAngle / 2) * (Math.PI / 180)
    const angles = getOuterAngles()
    const controlAngles1 = angles.map(angle => angle + Math.PI - halfAngle)
    const controlAngles2 = angles.map(angle => angle + Math.PI + halfAngle)

    const displacement1 = controlAngles1.map(angle => polarToCartesian(angle, controlDistance))
    const displacement2 = controlAngles2.map(angle => polarToCartesian(angle, controlDistance))
    const controlPoints1 = zip(outer, displacement1).map(addPoints)
    const controlPoints2 = zip(outer, displacement2).map(addPoints)

    return [outer, controlPoints1, controlPoints2]
  }

  constructPath(outer, control1, control2) {
    return `M ${outer[0]} C ${control1[0]} ${control2[2]} ${outer[2]}
                          C ${control1[2]} ${control2[4]} ${outer[4]}
                          C ${control1[4]} ${control2[1]} ${outer[1]}
                          C ${control1[1]} ${control2[3]} ${outer[3]}
                          C ${control1[3]} ${control2[0]} ${outer[0]}
                          Z`
  }
}

export default new CrossingCubicStar()
