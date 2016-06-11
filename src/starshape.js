/* global $ */

import { initializeOptions } from './uri.js'
import { initializeControls } from './controls.js'
import { initializeStars } from './star.js'
import { initializeColors } from './colors.js'

$(document).ready(() => {
  const options = initializeOptions()
  initializeControls(options)
  initializeStars(options)
  initializeColors(options)
})
