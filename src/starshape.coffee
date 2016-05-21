$innerRadius = null
$straightPercentage = null
$controlPercentage = null
drawStarFunction = null
uri = null

refreshForeground = (color) ->
  $("#swatch").css("color", color.toHexString())

refreshBackground = (color) ->
  if color?
    $("#swatch").css("background-color", color.toHexString())
  else
    $("#swatch").css("background-color", "")


setShapeToCircular = () ->
  drawStarFunction = drawStarWithCircularTips
  $("#control-point-section").css("visibility", "collapse")
  updateUrlQuery("s", "circular")
  refreshStarPath()

setShapeToQuadratic = () ->
  drawStarFunction = drawStarWithQuadraticTips
  $("#control-point-section").css("visibility", "collapse")
  updateUrlQuery("s", "quadratic")
  refreshStarPath()

setShapeToCubic = () ->
  drawStarFunction = drawStarWithCubicTips
  $("#control-point-section").css("visibility", "visible")
  updateUrlQuery("s", "cubic")
  refreshStarPath()


refreshStarPath = () ->
  if $straightPercentage.val() == "100"
    drawLinearStar()
  else
    drawStarFunction()


updateSlider = (sliderElement, value) ->
  $(".rangeslider__handle", sliderElement.$range).text(value)
  refreshStarPath()


updateUrlQuery = (key, value) ->
  uri.search (queryParams) ->
    queryParams[key] = value
    return
  history.replaceState(null, "", uri.resource())


initializeOptions = () ->
  uri = new URI()
  options = uri.search(true)

  options.s ?= "cubic"
  options.r ?= 1 - (2 / (1 + Math.sqrt(5)))
  options.l ?= 75
  options.c ?= 100
  options.fg ?= "fddc34"
  if options.bg == undefined    # null is a valid value for bg, so don't replace it with the default
    options.bg = "000000"

  options


$(document).ready () ->
  options = initializeOptions()

  $innerRadius = $("#inner-radius")
  $straightPercentage = $("#straight-percentage")
  $controlPercentage = $("#control-percentage")

  $("#circular").change(setShapeToCircular)
  $("#quadratic").change(setShapeToQuadratic)
  $("#cubic").change(setShapeToCubic)
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

  $innerRadius.rangeslider {
    polyfill: false
    onSlide: (_, value) -> updateSlider(this, value)
    onSlideEnd: (_, value) -> updateUrlQuery("r", value)
  }
  $innerRadius.val(options.r).change()

  $straightPercentage.rangeslider {
    polyfill: false
    onSlide: (_, value) -> updateSlider(this, value + "%")
    onSlideEnd: (_, value) -> updateUrlQuery("l", value)
  }
  $straightPercentage.val(options.l).change()

  $controlPercentage.rangeslider {
    polyfill: false
    onSlide: (_, value) -> updateSlider(this, value + "%")
    onSlideEnd: (_, value) -> updateUrlQuery("c", value)
  }
  $controlPercentage.val(options.c).change()



## Math functions for calculating star shapes


polarToCartesian = (angle, distance) ->
  x = Math.cos(angle) * distance
  y = Math.sin(angle) * distance
  {x: x, y: y}


pointAsString = (point) ->
  "" + point.x + "," + point.y


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


calculateInnerPoints = () ->
  innerRadius = $innerRadius.val()
  innerAngles = [-7*Math.PI/10, -3*Math.PI/10,   Math.PI/10, 5*Math.PI/10,  9*Math.PI/10]

  innerAngles.map (angle) -> polarToCartesian(angle, innerRadius)

innerPointStrings = () ->
  calculateInnerPoints().map pointAsString

calculateOuterPoints = () ->
  outerRadius = 1
  outerAngles = [-5*Math.PI/10,   -Math.PI/10, 3*Math.PI/10, 7*Math.PI/10, -9*Math.PI/10]

  outerAngles.map (angle) -> polarToCartesian(angle, outerRadius)

outerPointStrings = () ->
  calculateOuterPoints().map pointAsString

# This functions calculates the points in between each set of inner and outer points.
# If there are five points in each, there will be five in the output.
calculateSimpleIntermediatePoints = (innerPoints, outerPoints, percentage) ->
  fullDistance = calculateDistance(innerPoints[0], outerPoints[0])
  straightDistance = (percentage / 100) * fullDistance
  angles = _.zip(innerPoints, outerPoints).map ([innerPoint, outerPoint]) -> calculateAngle(innerPoint, outerPoint)

  displacementVectors = angles.map (angle) -> polarToCartesian(angle, straightDistance)
  _.zip(innerPoints, displacementVectors).map ([innerPoint, displacementVector]) -> {
    x: innerPoint.x + displacementVector.x
    y: innerPoint.y + displacementVector.y
  }

calculateIntermediatePoints = (innerPoints1, innerPoints2, outerPoints, percentage) ->
  points1 = calculateSimpleIntermediatePoints(innerPoints1, outerPoints, percentage)
  points2 = calculateSimpleIntermediatePoints(innerPoints2, outerPoints, percentage)

  [points1, points2]

calculateIntermediatePointsComingAndGoing = (innerPoints, outerPoints, percentage) ->
  shiftedInnerPoints = innerPoints.slice(1)
  shiftedInnerPoints.push(innerPoints[0])
  calculateIntermediatePoints(innerPoints, shiftedInnerPoints, outerPoints, percentage)


calculateLineToCurveTransitionPoints = (innerPoints, outerPoints) ->
  percentage = $straightPercentage.val()
  calculateIntermediatePointsComingAndGoing(innerPoints, outerPoints, percentage)

calculateControlPoints = (innerPoints, outerPoints) ->
  percentage = $controlPercentage.val()
  calculateIntermediatePointsComingAndGoing(innerPoints, outerPoints, percentage)

calculateControlPointsFromIntermediate = (intermediatePoints1, intermediatePoints2, outerPoints) ->
  percentage = $controlPercentage.val()
  calculateIntermediatePoints(intermediatePoints1, intermediatePoints2, outerPoints, percentage)


drawLinearStar = () ->
  innerPoints = innerPointStrings()
  outerPoints = outerPointStrings()
  points = _.flatten _.zip(innerPoints, outerPoints)

  pathString = "M " + points.shift() + " L "
  pathString += points.join(" ")
  pathString += " Z"

  $("#star").attr("d", pathString)

drawQuadraticStar = () ->
  innerPoints = innerPointStrings()
  outerPoints = outerPointStrings()

  firstPoint = innerPoints[0]
  innerPoints.push(innerPoints.shift())
  points = _.zip(outerPoints, innerPoints)

  sectionStrings = points.map ([outerPoint, innerPoint]) ->
    " Q " + outerPoint + " " + innerPoint

  pathString = "M " + firstPoint + sectionStrings.join('') + " Z"
  $("#star").attr("d", pathString)

drawCubicStar = () ->
  innerPoints = calculateInnerPoints()
  outerPoints = calculateOuterPoints()
  [controlPoints1, controlPoints2] = calculateControlPoints(innerPoints, outerPoints)

  firstPoint = pointAsString(innerPoints[0])
  innerPoints.push(innerPoints.shift())
  points = _.zip(controlPoints1.map(pointAsString), controlPoints2.map(pointAsString), innerPoints.map(pointAsString))

  sectionStrings = points.map ([control1, control2, inner]) ->
    " C #{ control1 } #{ control2 } #{ inner }"

  pathString = "M #{ firstPoint } " + sectionStrings.join('') + " Z"
  $("#star").attr("d", pathString)


drawStarWithCircularTips = () ->
  innerPoints = calculateInnerPoints()
  outerPoints = calculateOuterPoints()
  [intermediatePoints1, intermediatePoints2] = calculateLineToCurveTransitionPoints(innerPoints, outerPoints)

  radius = calculateRadius(intermediatePoints1[0], outerPoints[0], intermediatePoints2[0])

  points = _.zip(innerPoints.map(pointAsString), intermediatePoints1.map(pointAsString), intermediatePoints2.map(pointAsString))

  sectionStrings = points.map ([inner, intermediate1, intermediate2]) ->
    "#{ inner } L #{ intermediate1 } A #{ radius } #{ radius } 0 0 1 #{ intermediate2 }"
  pathString = "M " + sectionStrings.join(" L ") + " Z"
  $("#star").attr("d", pathString)

drawStarWithQuadraticTips = () ->
  if $straightPercentage.val() == "0"
    drawQuadraticStar()
    return

  innerPoints = calculateInnerPoints()
  outerPoints = calculateOuterPoints()
  [intermediatePoints1, intermediatePoints2] = calculateLineToCurveTransitionPoints(innerPoints, outerPoints)

  points = _.zip(innerPoints.map(pointAsString), intermediatePoints1.map(pointAsString), outerPoints.map(pointAsString), intermediatePoints2.map(pointAsString))

  sectionStrings = points.map ([inner, intermediate1, outer, intermediate2]) ->
    "#{ inner } L #{ intermediate1 } Q #{ outer } #{ intermediate2 }"
  pathString = "M " + sectionStrings.join(" L ") + " Z"
  $("#star").attr("d", pathString)

drawStarWithCubicTips = () ->
  if $straightPercentage.val() == "0"
    drawCubicStar()
    return

  innerPoints = calculateInnerPoints()
  outerPoints = calculateOuterPoints()
  [intermediatePoints1, intermediatePoints2] = calculateLineToCurveTransitionPoints(innerPoints, outerPoints)
  [controlPoints1, controlPoints2] = calculateControlPointsFromIntermediate(intermediatePoints1, intermediatePoints2, outerPoints)

  points = _.zip(innerPoints.map(pointAsString), intermediatePoints1.map(pointAsString), controlPoints1.map(pointAsString), controlPoints2.map(pointAsString), intermediatePoints2.map(pointAsString))

  sectionStrings = points.map ([inner, intermediate1, control1, control2, intermediate2]) ->
    "#{ inner } L #{ intermediate1 } C #{ control1 } #{ control2 } #{ intermediate2 }"
  pathString = "M " + sectionStrings.join(" L ") + " Z"
  $("#star").attr("d", pathString)
