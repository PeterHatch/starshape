import { updateStarPath } from './shapes.js'
import { addOption, removeOption, updateUrlQuery } from './url.js'

const sliders = new Map()
sliders.add = function addSlider(slider) {
  this.set(slider.name, slider)
}

class Slider {
  constructor(name, urlKey, defaultValue, initialValue) {
    this.name = name
    this.element = document.getElementById(name)
    this.outputElement = document.getElementById(`${name}-value`)
    this.sectionElement = document.getElementById(`${name}-section`)
    this.isVisible = true
    this.urlKey = urlKey

    this.element.addEventListener('input', () => { this.onInput() })
    this.element.addEventListener('change', () => { this.onChange() })
    const value = initialValue === undefined ? defaultValue : initialValue
    this.element.value = value
    this.updateText()

    this.initializeCssRules()
  }

  onInput() {
    this.updateText()
    this.updateBackground()
    updateStarPath()
  }

  onChange() {
    this.onInput()
    updateUrlQuery(this.urlKey, this.val())
  }

  val() {
    return this.element.value
  }

  show() {
    if (this.isVisible) {
      return this
    }

    this.sectionElement.style.display = ''
    this.updateBackground()
    this.isVisible = true
    addOption(this.urlKey, this.val())
    return this
  }

  hide() {
    if (!this.isVisible) {
      return this
    }

    this.sectionElement.style.display = 'none'
    this.isVisible = false
    removeOption(this.urlKey)
    return this
  }

  formattedValue() {
    return this.val()
  }

  updateText() {
    this.outputElement.textContent = this.formattedValue()
  }


  initializeCssRules() {
    const stylesheet = document.styleSheets[0]
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
    const thumbWidth = 30  // If the CSS for the thumb width changes, so must this line
    const trackWidth = this.element.scrollWidth
    const minFilledFraction = (thumbWidth / 2) / trackWidth
    const fillableFraction = (trackWidth - thumbWidth) / trackWidth

    const min = this.element.min
    const max = this.element.max
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
  formattedValue() {
    return `${super.formattedValue()}%`
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
