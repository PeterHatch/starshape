import 'babel-polyfill'

import $ from 'jquery'
import 'spectrum-colorpicker'

import { initializeOptions } from './uri.js'
import { initializeSliders, resizeSliders } from './sliders.js'
import { initializeShapes } from './shapes.js'
import { initializeColors } from './colors.js'

$(document).ready(() => {
  const options = initializeOptions()
  initializeSliders(options)
  initializeShapes(options)
  initializeColors(options)

  window.addEventListener('resize', resizeSliders)
})
