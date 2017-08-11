import starWithCircularTips from './shapes/star-with-circular-tips'
import starWithQuadraticTips from './shapes/star-with-quadratic-tips'
import starWithCubicTips from './shapes/star-with-cubic-tips'
import crossingCubicStar from './shapes/crossing-cubic-star'

export { updateStarPath } from './shapes/base-star'

export function initializeShapes(options) {
  const initialShape = options.s === undefined ? 'crossingcubic' : options.s

  document.getElementById('circular').addEventListener('change', starWithCircularTips.use)
  document.getElementById('quadratic').addEventListener('change', starWithQuadraticTips.use)
  document.getElementById('cubic').addEventListener('change', starWithCubicTips.use)
  document.getElementById('crossingcubic').addEventListener('change', crossingCubicStar.use)

  const initialElement = document.getElementById(initialShape)
  initialElement.checked = true

  initialElement.dispatchEvent(new Event('change'))
}
