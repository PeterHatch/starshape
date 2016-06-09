/* global $ _ URI */

let currentStar = null
let uri = null

function updateUrlQuery(key, value) {
  uri.search((queryParams) => {
    queryParams[key] = value
  })
  history.replaceState(null, '', uri.resource())
}


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
        currentStar.refreshPath()
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


function showControls(...visibleControls) {
  for (const [controlName, control] of controls) {
    if (visibleControls.includes(controlName)) {
      control.show()
    } else {
      control.hide()
    }
  }
}


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


function initializeOptions() {
  uri = new URI()
  const options = uri.search(true)

  if (options.s === undefined) {
    options.s = 'crossingcubic'
  }
  if (options.fg === undefined) {
    options.fg = 'fddc34'
  }
  if (options.bg === undefined) {
    options.bg = '000000'
  }

  return options
}


$(document).ready(() => {
  const options = initializeOptions()

  controls.add(new Slider('inner-radius', 'r', 1 - (2 / (1 + Math.sqrt(5))), options.r))
  controls.add(new PercentSlider('straight-percentage', 'l', 75, options.l))
  controls.add(new PercentSlider('control-percentage', 'c', 100, options.c))
  controls.add(new Slider('control-angle', 'ca', 180, options.ca))
  controls.add(new Slider('control-distance', 'cd', 0.15, options.cd))

  $('#circular').change(starWithCircularTips.use)
  $('#quadratic').change(starWithQuadraticTips.use)
  $('#cubic').change(starWithCubicTips.use)
  $('#crossingcubic').change(crossingCubicStar.use)
  $(`#${options.s}`).prop('checked', true)
  $('input[name=shape]:checked').change()

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


// Utility math functions for calculating star shapes, used by Star.points functions

class Point {
  constructor(x, y) {
    this.x = x
    this.y = y
  }

  toString() {
    return `${this.x},${this.y}`
  }
}

function polarToCartesian(angle, distance) {
  const x = Math.cos(angle) * distance
  const y = Math.sin(angle) * distance
  return new Point(x, y)
}

function addPoints([point1, point2]) {
  return new Point(point1.x + point2.x, point1.y + point2.y)
}

function calculateDistance(point1, point2) {
  return Math.sqrt(Math.pow(point1.x - point2.x, 2) + Math.pow(point1.y - point2.y, 2))
}

function calculateAngle(point1, point2) {
  return Math.atan2(point2.y - point1.y, point2.x - point1.x)
}


// a is an intermediate point, b an outer point, and c another intermediate point.
//
// This currently relies on the line AC being horizontal (to simplify calculation of angle CAB).
//
// M is the midpoint of AC, and X is the center of the circle with radius R we are solving for.
function calculateRadius(a, b, c) {
  const angleCAB = calculateAngle(a, b)
  const angleCAX = angleCAB + (Math.PI / 2)
  const lengthAM = calculateDistance(a, c) / 2

  return lengthAM * (1 / Math.cos(angleCAX))
}


function innerPoints(radius) {
  const innerAngles = [-7 * Math.PI / 10, -3 * Math.PI / 10, Math.PI / 10, 5 * Math.PI / 10, 9 * Math.PI / 10]
  return innerAngles.map((angle) => polarToCartesian(angle, radius))
}

function outerAngles() {
  return [-5 * Math.PI / 10, -Math.PI / 10, 3 * Math.PI / 10, 7 * Math.PI / 10, -9 * Math.PI / 10]
}

function outerPoints(radius = 1) {
  return outerAngles().map((angle) => polarToCartesian(angle, radius))
}

// This functions calculates the points in between each set of inner and outer points.
// If there are five points in each, there will be five in the output.
function calculateSimpleIntermediatePoints(innerPoints, outerPoints, percentage) {
  const fullDistance = calculateDistance(innerPoints[0], outerPoints[0])
  const straightDistance = (percentage / 100) * fullDistance
  const angles = _.zip(innerPoints, outerPoints).map(([innerPoint, outerPoint]) => calculateAngle(innerPoint, outerPoint))

  const displacementVectors = angles.map((angle) => polarToCartesian(angle, straightDistance))
  return _.zip(innerPoints, displacementVectors).map(addPoints)
}

function calculateIntermediatePoints(innerPoints1, innerPoints2, outerPoints, percentage) {
  const points1 = calculateSimpleIntermediatePoints(innerPoints1, outerPoints, percentage)
  const points2 = calculateSimpleIntermediatePoints(innerPoints2, outerPoints, percentage)

  return [points1, points2]
}

function calculateIntermediatePointsComingAndGoing(innerPoints, outerPoints, percentage) {
  const shiftedInnerPoints = innerPoints.slice(1)
  shiftedInnerPoints.push(innerPoints[0])
  return calculateIntermediatePoints(innerPoints, shiftedInnerPoints, outerPoints, percentage)
}


function controlVals(...controlNames) {
  return controlNames.map((name) => controls.get(name).val())
}

class Star {
  constructor(name, controls) {
    this.name = name
    this.controls = controls
    this.use = () => {
      currentStar = this
      showControls(...this.controls)
      updateUrlQuery('s', this.name)
      this.refreshPath()
    }
  }

  refreshPath() {
    const pathString = this.path(...controlVals(...this.controls))
    $('#star').attr('d', pathString)
  }

  path(...inputs) {
    const points = this.points(...inputs)
    return this.constructPath(...points)
  }
}

class InnerAndIntermediateStar extends Star {
  points(innerRadius, percentage) {
    const outer = outerPoints()
    const inner = innerPoints(innerRadius)
    const [intermediate1, intermediate2] = calculateIntermediatePointsComingAndGoing(inner, outer, percentage)

    return [inner, intermediate1, intermediate2, outer]
  }
}

class LinearStar extends Star {
  constructor() {
    super('linear', ['inner-radius'])
  }

  points(innerRadius) {
    return [innerPoints(innerRadius), outerPoints()]
  }

  constructPath(inner, outer) {
    const points = _.flatten(_.zip(inner, outer))
    return `M ${points.join(' L ')} Z`
  }
}

class StarWithCircularTips extends InnerAndIntermediateStar {
  constructor() {
    super('circular', ['inner-radius', 'straight-percentage'])
  }

  path(innerRadius, straightPercentage) {
    if (straightPercentage === '100') {
      return linearStar.path(innerRadius)
    }

    return super.path(innerRadius, straightPercentage)
  }

  points(innerRadius, straightPercentage) {
    const [inner, intermediate1, intermediate2, outer] = super.points(innerRadius, straightPercentage)
    const radius = calculateRadius(intermediate1[0], outer[0], intermediate2[0])

    return [inner, intermediate1, intermediate2, radius]
  }

  constructPath(inner, intermediate1, intermediate2, radius) {
    const points = _.zip(inner, intermediate1, intermediate2)

    const sectionStrings = points.map(([inner, intermediate1, intermediate2]) =>
        `${inner} L ${intermediate1} A ${radius} ${radius} 0 0 1 ${intermediate2}`)
    return `M ${sectionStrings.join(' L ')} Z`
  }
}

class QuadraticStar extends Star {
  constructor() {
    super(null, ['inner-radius'])
  }

  points(innerRadius) {
    return [innerPoints(innerRadius), outerPoints()]
  }

  constructPath(inner, outer) {
    const first = inner[0]
    inner.push(inner.shift())
    const points = _.zip(outer, inner)

    const sectionStrings = points.map(([outer, inner]) =>
        `Q ${outer} ${inner}`)

    return `M ${first} ${sectionStrings.join(' ')} Z`
  }
}

class StarWithQuadraticTips extends InnerAndIntermediateStar {
  constructor() {
    super('quadratic', ['inner-radius', 'straight-percentage'])
  }

  path(innerRadius, straightPercentage) {
    if (straightPercentage === '100') {
      return linearStar.path(innerRadius)
    }
    if (straightPercentage === '0') {
      return quadraticStar.path(innerRadius)
    }

    return super.path(innerRadius, straightPercentage)
  }

  constructPath(inner, intermediate1, intermediate2, outer) {
    const points = _.zip(inner, intermediate1, outer, intermediate2)

    const sectionStrings = points.map(([inner, intermediate1, outer, intermediate2]) =>
        `${inner} L ${intermediate1} Q ${outer} ${intermediate2}`)
    return `M ${sectionStrings.join(' L ')} Z`
  }
}

class CubicStar extends InnerAndIntermediateStar {
  constructor() {
    super(null, ['inner-radius', 'control-percentage'])
  }

  points(innerRadius, controlPercentage) {
    const [inner, control1, control2, _outer] = super.points(innerRadius, controlPercentage)
    return [inner, control1, control2]
  }

  constructPath(inner, control1, control2) {
    const first = inner[0]
    inner.push(inner.shift())
    const points = _.zip(control1, control2, inner)

    const sectionStrings = points.map(([control1, control2, inner]) =>
        `C ${control1} ${control2} ${inner}`)
    return `M ${first} ${sectionStrings.join(' ')} Z`
  }
}

class StarWithCubicTips extends Star {
  constructor() {
    super('cubic', ['inner-radius', 'straight-percentage', 'control-percentage'])
  }

  path(innerRadius, straightPercentage, controlPercentage) {
    if (straightPercentage === '100') {
      return linearStar.path(innerRadius)
    }
    if (straightPercentage === '0') {
      return cubicStar.path(innerRadius, controlPercentage)
    }

    return super.path(innerRadius, straightPercentage, controlPercentage)
  }

  points(innerRadius, straightPercentage, controlPercentage) {
    const outer = outerPoints()
    const inner = innerPoints(innerRadius)
    const [intermediate1, intermediate2] = calculateIntermediatePointsComingAndGoing(inner, outer, straightPercentage)
    const [control1, control2] = calculateIntermediatePoints(intermediate1, intermediate2, outer, controlPercentage)

    return [inner, intermediate1, intermediate2, control1, control2]
  }

  constructPath(inner, intermediate1, intermediate2, control1, control2) {
    const points = _.zip(inner, intermediate1, control1, control2, intermediate2)

    const sectionStrings = points.map(([inner, intermediate1, control1, control2, intermediate2]) =>
        `${inner} L ${intermediate1} C ${control1} ${control2} ${intermediate2}`)
    return `M ${sectionStrings.join(' L ')} Z`
  }
}

class CrossingCubicStar extends Star {
  constructor() {
    super('crossingcubic', ['control-angle', 'control-distance'])
  }

  points(controlAngle, controlDistance) {
    const outer = outerPoints()

    controlAngle = (controlAngle / 2) * (Math.PI / 180)
    const angles = outerAngles()
    const controlAngles1 = angles.map((angle) => angle + Math.PI - controlAngle)
    const controlAngles2 = angles.map((angle) => angle + Math.PI + controlAngle)

    const displacement1 = controlAngles1.map((angle) => polarToCartesian(angle, controlDistance))
    const displacement2 = controlAngles2.map((angle) => polarToCartesian(angle, controlDistance))
    const controlPoints1 = _.zip(outer, displacement1).map(addPoints)
    const controlPoints2 = _.zip(outer, displacement2).map(addPoints)

    return [outer, controlPoints1, controlPoints2]
  }

  constructPath(outer, control1, control2) {
    return `M ${outer[0]} C ${control1[0]} ${control2[2]} ${outer[2]}
                          C ${control1[2]} ${control2[4]} ${outer[4]}
                          C ${control1[4]} ${control2[1]} ${outer[1]}
                          C ${control1[1]} ${control2[3]} ${outer[3]}
                          C ${control1[3]} ${control2[0]} ${outer[0]}
                          Z`
  }
}


const linearStar = new LinearStar()
const starWithCircularTips = new StarWithCircularTips()
const quadraticStar = new QuadraticStar()
const starWithQuadraticTips = new StarWithQuadraticTips()
const cubicStar = new CubicStar()
const starWithCubicTips = new StarWithCubicTips()
const crossingCubicStar = new CrossingCubicStar()
