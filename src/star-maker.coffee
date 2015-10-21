$innerRadius = null
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


setShapeToLinear = () ->
  drawStarFunction = drawLinearStar
  refreshStarPath()

setShapeToQuadratic = () ->
  drawStarFunction = drawQuadraticStar
  refreshStarPath()

setShapeToCubic = () ->
  drawStarFunction = drawCubicStar
  refreshStarPath()


refreshStarPath = () ->
  drawStarFunction()


updateRadiusSlider = () ->
  $(".rangeslider__handle", this.$range).text(this.value)
  refreshStarPath()


$(document).ready () ->
  $innerRadius = $("#inner-radius")

  $("#straight").change(setShapeToLinear)
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
  $innerRadius.val(0.5).change()
