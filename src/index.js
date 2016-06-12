import $ from 'jquery'
import 'rangeslider.js'
import 'spectrum-colorpicker'

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
