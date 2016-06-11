/* global $ */

import { initializeOptions } from './uri.js'
import { initializeSliders } from './sliders.js'
import { initializeShapes } from './shapes.js'
import { initializeColors } from './colors.js'

$(document).ready(() => {
  const options = initializeOptions()
  initializeSliders(options)
  initializeShapes(options)
  initializeColors(options)
})
