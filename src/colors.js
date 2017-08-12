/* global $ */
import { updateUrlQuery } from './url'

function refreshForeground(color) {
  document.getElementById('swatch').style.color = color.toHexString()
}

function refreshBackground(color) {
  if (color !== null) {
    document.getElementById('swatch').style.backgroundColor = color.toHexString()
  } else {
    document.getElementById('swatch').style.backgroundColor = ''
  }
}

export function initializeColors(options) {
  const fgColor = options.fg === undefined ? 'fddc34' : options.fg
  const bgColor = options.bg === undefined ? '000000' : options.bg

  $('#fg-color-picker').spectrum({
    showInput: true,
    color: fgColor,
    move: refreshForeground,
    hide: refreshForeground,
    change: (color) => { updateUrlQuery('fg', color.toHex()) },
  })

  $('#bg-color-picker').spectrum({
    showInput: true,
    color: bgColor,
    allowEmpty: true,
    move: refreshBackground,
    hide: refreshBackground,
    change: (color) => { updateUrlQuery('bg', color !== null ? color.toHex() : null) },
  })

  refreshForeground($('#fg-color-picker').spectrum('get'))
  refreshBackground($('#bg-color-picker').spectrum('get'))
}
