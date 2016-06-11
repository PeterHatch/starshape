/* global $ */

import { initializeOptions, updateUrlQuery } from './uri.js'
import { initializeControls } from './controls.js'
import { initializeStars } from './star.js'

function refreshForeground(color) {
  $('#swatch').css('color', color.toHexString())
}

function refreshBackground(color) {
  if (color !== null) {
    $('#swatch').css('background-color', color.toHexString())
  } else {
    $('#swatch').css('background-color', '')
  }
}


$(document).ready(() => {
  const options = initializeOptions()
  initializeControls(options)
  initializeStars(options)

  $('#fg-color-picker').spectrum({
    showInput: true,
    color: options.fg,
    move: refreshForeground,
    hide: refreshForeground,
    change: (color) => { updateUrlQuery('fg', color.toHex()) },
  })

  $('#bg-color-picker').spectrum({
    showInput: true,
    color: options.bg,
    allowEmpty: true,
    move: refreshBackground,
    hide: refreshBackground,
    change: (color) => { updateUrlQuery('bg', color !== null ? color.toHex() : null) },
  })

  refreshForeground($('#fg-color-picker').spectrum('get'))
  refreshBackground($('#bg-color-picker').spectrum('get'))
})
