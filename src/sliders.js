import $ from 'jquery'

import { updateStarPath } from './shapes.js'
import { updateUrlQuery } from './uri.js'

const sliders = new Map()
sliders.add = function addSlider(slider) {
  this.set(slider.name, slider)
}

class Slider {
  constructor(name, uriKey, defaultValue, initialValue) {
    this.name = name
    this._element = document.getElementById(name)
    this._output = document.getElementById(`${name}-value`)
    this._section = $(`#${name}-section`)
    this._isVisible = true
    this._uriKey = uriKey

    this._element.addEventListener('input', (event) => {
      this._updateText(event.currentTarget.value)
      updateStarPath()
      this.updateBackground()  // This is not needed for IE, and not called because IE only does change events
    })
    this._element.addEventListener('change', (event) => {
      this._updateText(event.currentTarget.value)
      updateStarPath()
      updateUrlQuery(this._uriKey, event.currentTarget.value)
    })
    const value = initialValue === undefined ? defaultValue : initialValue
    this._element.value = value
    this._updateText(value)

    this.initializeCssRules()
  }

  val() {
    return this._element.value
  }

  show() {
    if (this._isVisible) {
      return this
    }

    this._section.css('visibility', 'visible')
    this.updateBackground()
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
    this._output.textContent = this._format(value)
  }

  initializeCssRules() {
    const stylesheet = document.styleSheets[1]
    const property = this.calculateCssForBackground()
    let ruleIndex
    try {
      ruleIndex = stylesheet.insertRule(
        `#${this.name}::-webkit-slider-runnable-track {${property} }`,
        stylesheet.cssRules.length)
    } catch (e) {
      if (e.name !== 'SyntaxError') {
        throw e
      }
      try {
        ruleIndex = stylesheet.insertRule(
          `#${this.name}::-moz-range-track {${property}}`,
          stylesheet.cssRules.length)
      } catch (e2) {
        if (e2.name !== 'SyntaxError') {
          throw e2
        }
      }
    }
    if (ruleIndex !== undefined) {
      this.dynamicStyle = stylesheet.cssRules[ruleIndex].style
    } else {
      this.dynamicStyle = null
    }
  }
  calculateCssForBackground() {
    const thumbWidth = 20  // If the CSS for the thumb width changes, so must this line
    const trackWidth = this._element.scrollWidth
    const minFilledFraction = (thumbWidth / 2) / trackWidth
    const fillableFraction = (trackWidth - thumbWidth) / trackWidth

    const min = this._element.min
    const max = this._element.max
    const current = this.val()

    const currentFraction = (current - min) / (max - min)
    const filledFraction = (fillableFraction * currentFraction) + minFilledFraction
    const filledPercent = filledFraction * 100

    return `background-size: ${filledPercent}% 100%, 100% 100%`
  }
  updateBackground() {
    if (this.dynamicStyle !== null) {
      const property = this.calculateCssForBackground()
      this.dynamicStyle.cssText = property
    }
  }
}


class PercentSlider extends Slider {
  _format(value) {
    return `${value}%`
  }
}

export function initializeSliders(options) {
  sliders.add(new Slider('inner-radius', 'r', 1 - (2 / (1 + Math.sqrt(5))), options.r))
  sliders.add(new PercentSlider('straight-percentage', 'l', 75, options.l))
  sliders.add(new PercentSlider('control-percentage', 'c', 100, options.c))
  sliders.add(new Slider('control-angle', 'ca', 180, options.ca))
  sliders.add(new Slider('control-distance', 'cd', 0.15, options.cd))
}

export function resizeSliders() {
  for (const slider of sliders.values()) {
    slider.updateBackground()
  }
}

export function showSliders(...visibleSliders) {
  for (const [name, slider] of sliders) {
    if (visibleSliders.includes(name)) {
      slider.show()
    } else {
      slider.hide()
    }
  }
}

export function readSliders(...names) {
  return names.map((name) => sliders.get(name).val())
}
