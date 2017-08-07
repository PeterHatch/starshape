import $ from 'jquery/src/core'
import 'jquery/src/core/parseHTML'

import 'jquery/src/attributes/attr'
import 'jquery/src/attributes/classes'
import 'jquery/src/attributes/val'
import 'jquery/src/event/alias'
import 'jquery/src/css'
import 'jquery/src/css/showHide'
import 'jquery/src/data'
import 'jquery/src/deprecated'
import 'jquery/src/dimensions'
import 'jquery/src/manipulation'
import 'jquery/src/offset'

import 'spectrum-colorpicker'

import { updateUrlQuery } from './url.js'

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
