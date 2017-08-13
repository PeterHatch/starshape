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

  const event = document.createEvent('HTMLEvents')
  event.initEvent('change', true, false) // Deprecated, but needed for IE11
  initialElement.dispatchEvent(event)

  // The version we'd use if IE11 supported it
  // initialElement.dispatchEvent(new Event('change'))
}
