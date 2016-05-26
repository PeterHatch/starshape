currentStar = null
uri = null

controls = {}

class Slider
  constructor: (name, uriKey, defaultValue, initialValue) ->
    controls[name] = this
    @_element = $("#" + name)
    @_section = $("#" + name + "-section")
    @_isVisible = true
    @_uriKey = uriKey

    @_element.rangeslider {
      polyfill: false
      onSlide: @_onSlide
      onSlideEnd: @_onSlideEnd
    }

    value = if initialValue is undefined then defaultValue else initialValue
    @_element.val(value)
    @_updateText(value)

  val: () -> @_element.val()

  show: () ->
    if @_isVisible
      return this

    @_section.css("visibility", "visible")
    @_isVisible = true
    return this

  hide: () ->
    unless @_isVisible
      return this

    @_section.css("visibility", "collapse")
    @_isVisible = false
    return this

  _format: (value) -> value

  _updateText: (value) ->
    $(".rangeslider__handle", @_section).text(@_format(value))

  _onSlide: (_, value) =>
    @_updateText(value)
    currentStar.refreshPath()

  _onSlideEnd: (_, value) =>
    updateUrlQuery(@_uriKey, value)


class PercentSlider extends Slider
  _format: (value) -> value + "%"


showControls = (visibleControls...) ->
  for controlName, control of controls
    if controlName in visibleControls
      control.show()
    else
      control.hide()
  return


refreshForeground = (color) ->
  $("#swatch").css("color", color.toHexString())

refreshBackground = (color) ->
  if color?
    $("#swatch").css("background-color", color.toHexString())
  else
    $("#swatch").css("background-color", "")


updateUrlQuery = (key, value) ->
  uri.search (queryParams) ->
    queryParams[key] = value
    return
  history.replaceState(null, "", uri.resource())


initializeOptions = () ->
  uri = new URI()
  options = uri.search(true)

  options.s ?= "crossingcubic"
  options.fg ?= "fddc34"
  if options.bg == undefined    # null is a valid value for bg, so don't replace it with the default
    options.bg = "000000"

  options



$(document).ready () ->
  options = initializeOptions()

  new Slider("inner-radius", "r", 1 - (2 / (1 + Math.sqrt(5))), options.r)
  new PercentSlider("straight-percentage", "l", 75, options.l)
  new PercentSlider("control-percentage", "c", 100, options.c)
  new Slider("control-angle", "ca", 180, options.ca)
  new Slider("control-distance", "cd", 0.15, options.cd)

  $("#circular").change(starWithCircularTips.use)
  $("#quadratic").change(starWithQuadraticTips.use)
  $("#cubic").change(starWithCubicTips.use)
  $("#crossingcubic").change(crossingCubicStar.use)
  $("#" + options.s).prop("checked", true)
  $("input[name=shape]:checked").change()

  $("#fg-color-picker").spectrum {
    showInput: true
    color: options.fg
    move: refreshForeground
    hide: refreshForeground
    change: (color) -> updateUrlQuery("fg", color.toHex())
  }

  $("#bg-color-picker").spectrum {
    showInput: true
    color: options.bg
    allowEmpty: true
    move: refreshBackground
    hide: refreshBackground
    change: (color) -> updateUrlQuery("bg", if color isnt null then color.toHex() else null)
  }

  refreshForeground($("#fg-color-picker").spectrum("get"))
  refreshBackground($("#bg-color-picker").spectrum("get"))


## Utility math functions for calculating star shapes, used by Star.points functions

class Point
  constructor: (@x, @y) ->

  toString: () ->
    "#{@x},#{@y}"

polarToCartesian = (angle, distance) ->
  x = Math.cos(angle) * distance
  y = Math.sin(angle) * distance
  new Point(x, y)

addPoints = ([point1, point2]) ->
  new Point(point1.x + point2.x, point1.y + point2.y)

calculateDistance = (point1, point2) ->
  Math.sqrt(Math.pow(point1.x - point2.x, 2) + Math.pow(point1.y - point2.y, 2))

calculateAngle = (point1, point2) ->
  Math.atan2 point2.y - point1.y, point2.x - point1.x


# a is an intermediate point, b an outer point, and c another intermediate point.
#
# This currently relies on the line AC being horizontal (to simplify calculation of angle CAB).
#
# M is the midpoint of AC, and X is the center of the circle with radius R we are solving for.
calculateRadius = (a, b, c) ->
  angle_cab = calculateAngle a, b
  angle_cax = angle_cab + (Math.PI / 2)
  length_am = calculateDistance(a, c) / 2

  length_am * (1 / Math.cos(angle_cax))


innerPoints = (radius) ->
  innerAngles = [-7*Math.PI/10, -3*Math.PI/10,   Math.PI/10, 5*Math.PI/10,  9*Math.PI/10]
  innerAngles.map (angle) -> polarToCartesian(angle, radius)

outerAngles = () ->
  [-5*Math.PI/10,   -Math.PI/10, 3*Math.PI/10, 7*Math.PI/10, -9*Math.PI/10]

outerPoints = (radius = 1) ->
  outerAngles().map (angle) -> polarToCartesian(angle, radius)

# This functions calculates the points in between each set of inner and outer points.
# If there are five points in each, there will be five in the output.
calculateSimpleIntermediatePoints = (innerPoints, outerPoints, percentage) ->
  fullDistance = calculateDistance(innerPoints[0], outerPoints[0])
  straightDistance = (percentage / 100) * fullDistance
  angles = _.zip(innerPoints, outerPoints).map ([innerPoint, outerPoint]) -> calculateAngle(innerPoint, outerPoint)

  displacementVectors = angles.map (angle) -> polarToCartesian(angle, straightDistance)
  _.zip(innerPoints, displacementVectors).map(addPoints)

calculateIntermediatePoints = (innerPoints1, innerPoints2, outerPoints, percentage) ->
  points1 = calculateSimpleIntermediatePoints(innerPoints1, outerPoints, percentage)
  points2 = calculateSimpleIntermediatePoints(innerPoints2, outerPoints, percentage)

  [points1, points2]

calculateIntermediatePointsComingAndGoing = (innerPoints, outerPoints, percentage) ->
  shiftedInnerPoints = innerPoints.slice(1)
  shiftedInnerPoints.push(innerPoints[0])
  calculateIntermediatePoints(innerPoints, shiftedInnerPoints, outerPoints, percentage)


controlVals = (controlNames...) ->
  for name in controlNames
    controls[name].val()

class Star
  constructor: (@name, @controls) ->

  refreshPath: () =>
    pathString = @path(controlVals(@controls...)...)
    $("#star").attr("d", pathString)
    return

  use: () =>
    currentStar = this
    showControls(@controls...)
    updateUrlQuery("s", @name)
    @refreshPath()

  path: (inputs...) ->
    points = @points(inputs...)
    @constructPath(points...)

class InnerAndIntermediateStar extends Star
  points: (innerRadius, percentage) ->
    outer = outerPoints()
    inner = innerPoints(innerRadius)
    [intermediate1, intermediate2] = calculateIntermediatePointsComingAndGoing(inner, outer, percentage)

    [inner, intermediate1, intermediate2, outer]

class LinearStar extends Star
  constructor: () ->
    super("linear", ["inner-radius"])

  points: (innerRadius) ->
    [innerPoints(innerRadius), outerPoints()]

  constructPath: (inner, outer) ->
    points = _.flatten(_.zip(inner, outer))
    return "M " + points.join(" L ") + " Z"

class StarWithCircularTips extends InnerAndIntermediateStar
  constructor: () ->
    super("circular", ["inner-radius", "straight-percentage"])

  path: (innerRadius, straightPercentage) ->
    if straightPercentage == "100"
      return linearStar.path(innerRadius)
    else
      super(innerRadius, straightPercentage)

  points: (innerRadius, straightPercentage) ->
    [inner, intermediate1, intermediate2, outer] = super(innerRadius, straightPercentage)
    radius = calculateRadius(intermediate1[0], outer[0], intermediate2[0])

    return [inner, intermediate1, intermediate2, radius]

  constructPath: (inner, intermediate1, intermediate2, radius) ->
    points = _.zip(inner, intermediate1, intermediate2)

    sectionStrings = points.map ([inner, intermediate1, intermediate2]) ->
      "#{ inner } L #{ intermediate1 } A #{ radius } #{ radius } 0 0 1 #{ intermediate2 }"
    return "M " + sectionStrings.join(" L ") + " Z"

class QuadraticStar extends Star
  constructor: () ->
    super(null, ["inner-radius"])

  points: (innerRadius) ->
    [innerPoints(innerRadius), outerPoints()]

  constructPath: (inner, outer) ->
    first = inner[0]
    inner.push(inner.shift())
    points = _.zip(outer, inner)

    sectionStrings = points.map ([outer, inner]) ->
      "Q #{ outer } #{ inner }"

    return "M #{ first } " + sectionStrings.join(" ") + " Z"

class StarWithQuadraticTips extends InnerAndIntermediateStar
  constructor: () ->
    super("quadratic", ["inner-radius", "straight-percentage"])

  path: (innerRadius, straightPercentage) ->
    if straightPercentage == "100"
      return linearStar.path(innerRadius)
    if straightPercentage == "0"
      return quadraticStar.path(innerRadius)

    super(innerRadius, straightPercentage)

  constructPath: (inner, intermediate1, intermediate2, outer) ->
    points = _.zip(inner, intermediate1, outer, intermediate2)

    sectionStrings = points.map ([inner, intermediate1, outer, intermediate2]) ->
      "#{ inner } L #{ intermediate1 } Q #{ outer } #{ intermediate2 }"
    return "M " + sectionStrings.join(" L ") + " Z"

class CubicStar extends InnerAndIntermediateStar
  constructor: () ->
    super(null, ["inner-radius", "control-percentage"])

  points: (innerRadius, controlPercentage) ->
    [inner, control1, control2, outer] = super(innerRadius, controlPercentage)
    [inner, control1, control2]

  constructPath: (inner, control1, control2) ->
    first = inner[0]
    inner.push(inner.shift())
    points = _.zip(control1, control2, inner)

    sectionStrings = points.map ([control1, control2, inner]) ->
      "C #{ control1 } #{ control2 } #{ inner }"
    return "M #{ first } " + sectionStrings.join(" ") + " Z"

class StarWithCubicTips extends Star
  constructor: () ->
    super("cubic", ["inner-radius", "straight-percentage", "control-percentage"])

  path: (innerRadius, straightPercentage, controlPercentage) ->
    if straightPercentage == "100"
      return linearStar.path(innerRadius)
    if straightPercentage == "0"
      return cubicStar.path(innerRadius, controlPercentage)

    super(innerRadius, straightPercentage, controlPercentage)

  points: (innerRadius, straightPercentage, controlPercentage) ->
    outer = outerPoints()
    inner = innerPoints(innerRadius)
    [intermediate1, intermediate2] = calculateIntermediatePointsComingAndGoing(inner, outer, straightPercentage)
    [control1, control2] = calculateIntermediatePoints(intermediate1, intermediate2, outer, controlPercentage)

    return [inner, intermediate1, intermediate2, control1, control2]

  constructPath: (inner, intermediate1, intermediate2, control1, control2) ->
    points = _.zip(inner, intermediate1, control1, control2, intermediate2)

    sectionStrings = points.map ([inner, intermediate1, control1, control2, intermediate2]) ->
      "#{ inner } L #{ intermediate1 } C #{ control1 } #{ control2 } #{ intermediate2 }"
    return "M " + sectionStrings.join(" L ") + " Z"

class CrossingCubicStar extends Star
  constructor: () ->
    super("crossingcubic", ["control-angle", "control-distance"])

  points: (controlAngle, controlDistance) ->
    outer = outerPoints()

    controlAngle = (controlAngle / 2) * (Math.PI / 180)
    angles = outerAngles()
    controlAngles1 = angles.map (angle) ->
      angle + Math.PI - controlAngle
    controlAngles2 = angles.map (angle) ->
      angle + Math.PI + controlAngle

    displacement1 = controlAngles1.map (angle) -> polarToCartesian(angle, controlDistance)
    displacement2 = controlAngles2.map (angle) -> polarToCartesian(angle, controlDistance)
    controlPoints1 = _.zip(outer, displacement1).map(addPoints)
    controlPoints2 = _.zip(outer, displacement2).map(addPoints)

    [outer, controlPoints1, controlPoints2]

  constructPath: (outer, control1, control2) ->
    "M #{outer[0]} C #{control1[0]} #{control2[2]} #{outer[2]}
                   C #{control1[2]} #{control2[4]} #{outer[4]}
                   C #{control1[4]} #{control2[1]} #{outer[1]}
                   C #{control1[1]} #{control2[3]} #{outer[3]}
                   C #{control1[3]} #{control2[0]} #{outer[0]}
                   Z"


linearStar = new LinearStar()
starWithCircularTips = new StarWithCircularTips()
quadraticStar = new QuadraticStar()
starWithQuadraticTips = new StarWithQuadraticTips()
cubicStar = new CubicStar()
starWithCubicTips = new StarWithCubicTips()
crossingCubicStar = new CrossingCubicStar()
