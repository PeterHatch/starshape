drawStarFunction = null
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
    refreshStarPath()

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


setShapeToCircular = () ->
  drawStarFunction = drawStarWithCircularTips
  showControls("inner-radius", "straight-percentage")
  updateUrlQuery("s", "circular")
  refreshStarPath()

setShapeToQuadratic = () ->
  drawStarFunction = drawStarWithQuadraticTips
  showControls("inner-radius", "straight-percentage")
  updateUrlQuery("s", "quadratic")
  refreshStarPath()

setShapeToCubic = () ->
  drawStarFunction = drawStarWithCubicTips
  showControls("inner-radius", "straight-percentage", "control-percentage")
  updateUrlQuery("s", "cubic")
  refreshStarPath()

setShapeToCrossingCubic = () ->
  drawStarFunction = drawCrossingCubicStar
  showControls("control-angle", "control-distance")
  updateUrlQuery("s", "crossingcubic")
  refreshStarPath()


refreshStarPath = () ->
  if controls["straight-percentage"].val() == "100"
    drawLinearStar()
  else
    drawStarFunction()


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

  $("#circular").change(setShapeToCircular)
  $("#quadratic").change(setShapeToQuadratic)
  $("#cubic").change(setShapeToCubic)
  $("#crossingcubic").change(setShapeToCrossingCubic)
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


## Math functions for calculating star shapes


polarToCartesian = (angle, distance) ->
  x = Math.cos(angle) * distance
  y = Math.sin(angle) * distance
  {x: x, y: y}


pointAsString = (point) ->
  "" + point.x + "," + point.y

addPoints = ([point1, point2]) ->
  {
    x: point1.x + point2.x
    y: point1.y + point2.y
  }


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


innerStarPoints = (innerRadius) ->
  outer = outerPoints()
  inner = innerPoints(innerRadius)

  return [
    outer.map(pointAsString)
    inner.map(pointAsString)
  ]

linearStarPoints = innerStarPoints
quadraticStarPoints = innerStarPoints

innerAndIntermediatePoints = (innerRadius, percentage) ->
  outer = outerPoints()
  inner = innerPoints(innerRadius)
  [intermediate1, intermediate2] = calculateIntermediatePointsComingAndGoing(inner, outer, percentage)

  return [
    outer.map(pointAsString)
    inner.map(pointAsString)
    intermediate1.map(pointAsString)
    intermediate2.map(pointAsString)
  ]

starWithQuadraticTipsPoints = innerAndIntermediatePoints

cubicStarPoints = (innerRadius, controlPercentage) ->
  [outer, inner, control1, control2] = innerAndIntermediatePoints(innerRadius, controlPercentage)
  return [inner, control1, control2]

starWithCircularTipsPoints = (innerRadius, straightPercentage) ->
  outer = outerPoints()
  inner = innerPoints(innerRadius)
  [intermediate1, intermediate2] = calculateIntermediatePointsComingAndGoing(inner, outer, straightPercentage)

  radius = calculateRadius(intermediate1[0], outer[0], intermediate2[0])

  return [
    inner.map(pointAsString)
    intermediate1.map(pointAsString)
    intermediate2.map(pointAsString)
    radius
  ]

starWithCubicTipsPoints = (innerRadius, straightPercentage, controlPercentage) ->
  outer = outerPoints()
  inner = innerPoints(innerRadius)
  [intermediate1, intermediate2] = calculateIntermediatePointsComingAndGoing(inner, outer, straightPercentage)
  [control1, control2] = calculateIntermediatePoints(intermediate1, intermediate2, outer, controlPercentage)

  return [
    inner.map(pointAsString)
    intermediate1.map(pointAsString)
    intermediate2.map(pointAsString)
    control1.map(pointAsString)
    control2.map(pointAsString)
  ]

crossingCubicPoints = (controlAngle, controlDistance) ->
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

  [outer.map(pointAsString), controlPoints1.map(pointAsString), controlPoints2.map(pointAsString)]


linearStarPath = (innerRadius) ->
  [outer, inner] = linearStarPoints(innerRadius)

  points = _.flatten(_.zip(inner, outer))
  return "M " + points.join(" L ") + " Z"

quadraticStarPath = (innerRadius) ->
  [outer, inner] = quadraticStarPoints(innerRadius)

  first = inner[0]
  inner.push(inner.shift())
  points = _.zip(outer, inner)

  sectionStrings = points.map ([outer, inner]) ->
    "Q #{ outer } #{ inner }"

  return "M #{ first } " + sectionStrings.join(" ") + " Z"

cubicStarPath = (innerRadius, controlPercentage) ->
  [inner, control1, control2] = cubicStarPoints(innerRadius, controlPercentage)

  first = inner[0]
  inner.push(inner.shift())
  points = _.zip(control1, control2, inner)

  sectionStrings = points.map ([control1, control2, inner]) ->
    "C #{ control1 } #{ control2 } #{ inner }"

  return "M #{ first } " + sectionStrings.join(" ") + " Z"

starWithCircularTipsPath = (innerRadius, straightPercentage) ->
  [inner, intermediate1, intermediate2, radius] = starWithCircularTipsPoints(innerRadius, straightPercentage)
  points = _.zip(inner, intermediate1, intermediate2)

  sectionStrings = points.map ([inner, intermediate1, intermediate2]) ->
    "#{ inner } L #{ intermediate1 } A #{ radius } #{ radius } 0 0 1 #{ intermediate2 }"
  return "M " + sectionStrings.join(" L ") + " Z"

starWithQuadraticTipsPath = (innerRadius, straightPercentage) ->
  if straightPercentage == "0"
    return quadraticStarPath(innerRadius)

  [outer, inner, intermediate1, intermediate2] = starWithQuadraticTipsPoints(innerRadius, straightPercentage)
  points = _.zip(inner, intermediate1, outer, intermediate2)

  sectionStrings = points.map ([inner, intermediate1, outer, intermediate2]) ->
    "#{ inner } L #{ intermediate1 } Q #{ outer } #{ intermediate2 }"
  return "M " + sectionStrings.join(" L ") + " Z"

starWithCubicTipsPath = (innerRadius, straightPercentage, controlPercentage) ->
  if straightPercentage == "0"
    return cubicStarPath(innerRadius, controlPercentage)

  [inner, intermediate1, intermediate2, control1, control2] = starWithCubicTipsPoints(innerRadius, straightPercentage, controlPercentage)
  points = _.zip(inner, intermediate1, control1, control2, intermediate2)

  sectionStrings = points.map ([inner, intermediate1, control1, control2, intermediate2]) ->
    "#{ inner } L #{ intermediate1 } C #{ control1 } #{ control2 } #{ intermediate2 }"
  return "M " + sectionStrings.join(" L ") + " Z"

crossingCubicStarPath = (controlAngle, controlDistance) ->
  [outer, control1, control2] = crossingCubicPoints(controlAngle, controlDistance)
  "M #{outer[0]} C #{control1[0]} #{control2[2]} #{outer[2]}
                 C #{control1[2]} #{control2[4]} #{outer[4]}
                 C #{control1[4]} #{control2[1]} #{outer[1]}
                 C #{control1[1]} #{control2[3]} #{outer[3]}
                 C #{control1[3]} #{control2[0]} #{outer[0]}
                 Z"


setStarPath = (path) ->
  $("#star").attr("d", path)
  return

drawLinearStar = () ->
  innerRadius = controls["inner-radius"].val()
  path = linearStarPath(innerRadius)
  setStarPath(path)

drawStarWithCircularTips = () ->
  innerRadius = controls["inner-radius"].val()
  straightPercentage = controls["straight-percentage"].val()
  path = starWithCircularTipsPath(innerRadius, straightPercentage)
  setStarPath(path)

drawStarWithQuadraticTips = () ->
  innerRadius = controls["inner-radius"].val()
  straightPercentage = controls["straight-percentage"].val()
  path = starWithQuadraticTipsPath(innerRadius, straightPercentage)
  setStarPath(path)

drawStarWithCubicTips = () ->
  innerRadius = controls["inner-radius"].val()
  straightPercentage = controls["straight-percentage"].val()
  controlPercentage = controls["control-percentage"].val()
  path = starWithCubicTipsPath(innerRadius, straightPercentage, controlPercentage)
  setStarPath(path)

drawCrossingCubicStar = () ->
  controlAngle = controls["control-angle"].val()
  controlDistance = controls["control-distance"].val()
  path = crossingCubicStarPath(controlAngle, controlDistance)
  setStarPath(path)
