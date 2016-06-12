import $ from 'jquery'

import starWithCircularTips from './shapes/star-with-circular-tips.js'
import starWithQuadraticTips from './shapes/star-with-quadratic-tips.js'
import starWithCubicTips from './shapes/star-with-cubic-tips.js'
import crossingCubicStar from './shapes/crossing-cubic-star.js'

export { updateStarPath } from './shapes/base-star.js'

export function initializeShapes(options) {
  const initialShape = options.s === undefined ? 'crossingcubic' : options.s

  $('#circular').change(starWithCircularTips.use)
  $('#quadratic').change(starWithQuadraticTips.use)
  $('#cubic').change(starWithCubicTips.use)
  $('#crossingcubic').change(crossingCubicStar.use)
  $(`#${initialShape}`).prop('checked', true)
  $('input[name=shape]:checked').change()
}
