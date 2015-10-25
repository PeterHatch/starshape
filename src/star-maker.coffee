$innerRadius = null
$straightPercentage = null
$controlPercentage = null
drawStarFunction = null

refreshForeground = (color) ->
  $("#swatch").css("color", color.toHexString())


refreshBackground = (color) ->
  if color?
    $("#swatch").css("background-color", color.toHexString())
  else
    $("#swatch").css("background-color", "")


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

calculateIntermediatePoints = (innerPoints, outerPoints, percentage) ->
  fullDistance = calculateDistance(innerPoints[0], outerPoints[0])
  straightDistance = (percentage / 100) * fullDistance
  angles = _.zip(innerPoints, outerPoints).map ([innerPoint, outerPoint]) -> calculateAngle(innerPoint, outerPoint)

  displacementVectors = angles.map (angle) -> polarToCartesian(angle, straightDistance)
  _.zip(innerPoints, displacementVectors).map ([innerPoint, displacementVector]) -> {
    x: innerPoint.x + displacementVector.x
    y: innerPoint.y + displacementVector.y
  }

calculateLineToCurveTransitionPoints = (innerPoints, outerPoints) ->
  percentage = $straightPercentage.val()
  points1 = calculateIntermediatePoints(innerPoints, outerPoints, percentage)

  shiftedInnerPoints = innerPoints.slice(1)
  shiftedInnerPoints.push(innerPoints[0])
  points2 = calculateIntermediatePoints(shiftedInnerPoints, outerPoints, percentage)

  [points1, points2]

calculateControlPoints = (intermediatePoints1, intermediatePoints2, outerPoints) ->
  percentage = $controlPercentage.val()
  points1 = calculateIntermediatePoints(intermediatePoints1, outerPoints, percentage)
  points2 = calculateIntermediatePoints(intermediatePoints2, outerPoints, percentage)

  [points1, points2]


drawLinearStar = () ->
  innerPoints = innerPointStrings()
  outerPoints = outerPointStrings()
  points = _.flatten _.zip(innerPoints, outerPoints)

  pathString = "M " + points.shift() + " L "
  pathString += points.join(" ")
  pathString += " Z";

  $("#star").attr("d", pathString);

drawQuadraticStar = () ->
  innerPoints = innerPointStrings()
  outerPoints = outerPointStrings()

  firstPoint = innerPoints[0]
  innerPoints.push(innerPoints.shift())
  points = _.zip(outerPoints, innerPoints)

  sectionStrings = points.map ([outerPoint, innerPoint]) ->
    " Q " + outerPoint + " " + innerPoint

  pathString = "M " + firstPoint + sectionStrings.join('') + " Z"
  $("#star").attr("d", pathString);


# Does not account for control points, so is no longer used
drawCubicStar = () ->
  innerPoints = innerPointStrings()
  outerPoints = outerPointStrings()

  firstPoint = innerPoints[0]
  innerPoints.push(innerPoints.shift())
  points = _.zip(outerPoints, innerPoints)

  sectionStrings = points.map ([outerPoint, innerPoint]) ->
    " C " + outerPoint + " " + outerPoint + " " + innerPoint

  pathString = "M " + firstPoint + sectionStrings.join('') + " Z"
  $("#star").attr("d", pathString);

drawStarWithCircularTips = () ->
  innerPoints = calculateInnerPoints()
  outerPoints = calculateOuterPoints()
  [intermediatePoints1, intermediatePoints2] = calculateLineToCurveTransitionPoints(innerPoints, outerPoints)

  radius = calculateRadius(intermediatePoints1[0], outerPoints[0], intermediatePoints2[0])

  points = _.zip(innerPoints.map(pointAsString), intermediatePoints1.map(pointAsString), intermediatePoints2.map(pointAsString))

  sectionStrings = points.map ([inner, intermediate1, intermediate2]) ->
    "#{ inner } L #{ intermediate1 } A #{ radius } #{ radius } 0 0 1 #{ intermediate2 }"
  pathString = "M " + sectionStrings.join(" L ") + " Z"
  $("#star").attr("d", pathString);

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
  $("#star").attr("d", pathString);

drawStarWithCubicTips = () ->
  innerPoints = calculateInnerPoints()
  outerPoints = calculateOuterPoints()
  [intermediatePoints1, intermediatePoints2] = calculateLineToCurveTransitionPoints(innerPoints, outerPoints)
  [controlPoints1, controlPoints2] = calculateControlPoints(intermediatePoints1, intermediatePoints2, outerPoints)

  points = _.zip(innerPoints.map(pointAsString), intermediatePoints1.map(pointAsString), controlPoints1.map(pointAsString), controlPoints2.map(pointAsString), intermediatePoints2.map(pointAsString))

  sectionStrings = points.map ([inner, intermediate1, control1, control2, intermediate2]) ->
    "#{ inner } L #{ intermediate1 } C #{ control1 } #{ control2 } #{ intermediate2 }"
  pathString = "M " + sectionStrings.join(" L ") + " Z"
  $("#star").attr("d", pathString);


setShapeToCircular = () ->
  drawStarFunction = drawStarWithCircularTips
  refreshStarPath()

setShapeToQuadratic = () ->
  drawStarFunction = drawStarWithQuadraticTips
  refreshStarPath()

setShapeToCubic = () ->
  drawStarFunction = drawStarWithCubicTips
  refreshStarPath()


refreshStarPath = () ->
  if $straightPercentage.val() == "100"
    drawLinearStar()
  else
    drawStarFunction()


updateRadiusSlider = () ->
  $(".rangeslider__handle", this.$range).text(this.value)
  refreshStarPath()

updatePercentageSlider = () ->
  $(".rangeslider__handle", this.$range).text(this.value + "%")
  refreshStarPath()


$(document).ready () ->
  $innerRadius = $("#inner-radius")
  $straightPercentage = $("#straight-percentage")
  $controlPercentage = $("#control-percentage")

  $("#circular").change(setShapeToCircular)
  $("#quadratic").change(setShapeToQuadratic)
  $("#cubic").change(setShapeToCubic)
  $("input[name=shape]:checked").change()

  $("#fg-color-picker").spectrum {
    flat: true
    showInput: true
    showButtons: false
    color: "#fddc34"
    move: refreshForeground
    change: refreshForeground
  }
  $("#bg-color-picker").spectrum {
    flat: true
    showInput: true
    showButtons: false
    color: "black"
    allowEmpty: true
    move: refreshBackground
    change: refreshBackground
  }
  refreshForeground($("#fg-color-picker").spectrum("get"))
  refreshBackground($("#bg-color-picker").spectrum("get"))

  $innerRadius.rangeslider {
    polyfill: false
    onSlide: updateRadiusSlider
  }
  regularPolygonInnerRadius = 1 - (2 / (1 + Math.sqrt(5)))
  $innerRadius.val(regularPolygonInnerRadius).change()

  $straightPercentage.rangeslider {
    polyfill: false
    onSlide: updatePercentageSlider
  }
  $straightPercentage.val(75).change()

  $controlPercentage.rangeslider {
    polyfill: false
    onSlide: updatePercentageSlider
  }
  $controlPercentage.val(100).change()
