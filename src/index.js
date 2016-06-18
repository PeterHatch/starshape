import 'babel-polyfill'

import 'spectrum-colorpicker'

import { initializeOptions } from './uri.js'
import { initializeSliders, resizeSliders } from './sliders.js'
import { initializeShapes } from './shapes.js'
import { initializeColors } from './colors.js'


function ready() {
  const options = initializeOptions()
  initializeSliders(options)
  initializeShapes(options)
  initializeColors(options)

  window.addEventListener('resize', resizeSliders)
}

if (document.readyState !== 'loading') {
  ready()
} else {
  document.addEventListener('DOMContentLoaded', ready)
}
