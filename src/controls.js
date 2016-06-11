/* globals $ */

import { updateStarPath } from './star.js'
import { updateUrlQuery } from './uri.js'

const controls = new Map()
controls.add = function addControl(control) {
  this.set(control.name, control)
}

class Slider {
  constructor(name, uriKey, defaultValue, initialValue) {
    this.name = name
    this._element = $(`#${name}`)
    this._section = $(`#${name}-section`)
    this._isVisible = true
    this._uriKey = uriKey

    this._element.rangeslider({
      polyfill: false,
      onSlide: (_, value) => {
        this._updateText(value)
        updateStarPath()
      },
      onSlideEnd: (_, value) => {
        updateUrlQuery(this._uriKey, value)
      },
    })

    const value = initialValue === undefined ? defaultValue : initialValue
    this._element.val(value)
    this._updateText(value)
  }

  val() {
    return this._element.val()
  }

  show() {
    if (this._isVisible) {
      return this
    }

    this._section.css('visibility', 'visible')
    this._isVisible = true
    return this
  }

  hide() {
    if (!this._isVisible) {
      return this
    }

    this._section.css('visibility', 'collapse')
    this._isVisible = false
    return this
  }

  _format(value) {
    return value
  }

  _updateText(value) {
    $('.rangeslider__handle', this._section).text(this._format(value))
  }
}


class PercentSlider extends Slider {
  _format(value) {
    return `${value}%`
  }
}

export function initializeControls(options) {
  controls.add(new Slider('inner-radius', 'r', 1 - (2 / (1 + Math.sqrt(5))), options.r))
  controls.add(new PercentSlider('straight-percentage', 'l', 75, options.l))
  controls.add(new PercentSlider('control-percentage', 'c', 100, options.c))
  controls.add(new Slider('control-angle', 'ca', 180, options.ca))
  controls.add(new Slider('control-distance', 'cd', 0.15, options.cd))
}

export function showControls(...visibleControls) {
  for (const [controlName, control] of controls) {
    if (visibleControls.includes(controlName)) {
      control.show()
    } else {
      control.hide()
    }
  }
}

export function controlVals(...controlNames) {
  return controlNames.map((name) => controls.get(name).val())
}
