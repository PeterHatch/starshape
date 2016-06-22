import 'core-js/es6/map'
import 'core-js/fn/array/includes'
import 'core-js/fn/symbol'

import { initializeOptions } from './url.js'
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
