import { initializeOptions } from './url'
import { initializeSliders, resizeSliders } from './sliders'
import { initializeShapes } from './shapes'
import { initializeColors } from './colors'


function ready() {
  const options = initializeOptions()
  initializeSliders(options)
  initializeShapes(options)
  initializeColors(options)

  window.addEventListener('resize', resizeSliders)
}

if (document.readyState === 'complete') {
  ready()
} else {
  window.addEventListener('load', ready)
}
