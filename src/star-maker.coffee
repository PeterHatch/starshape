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


starPoints = () ->
  innerRadius = $innerRadius.val()
  outerRadius = 1;
  innerAngles = [-7*Math.PI/10, -3*Math.PI/10,   Math.PI/10, 5*Math.PI/10,  9*Math.PI/10]
  outerAngles = [-5*Math.PI/10,   -Math.PI/10, 3*Math.PI/10, 7*Math.PI/10, -9*Math.PI/10]

  points = []
  for i in [0..4]
    points.push polarToCartesian(innerAngles[i], innerRadius)
    points.push polarToCartesian(outerAngles[i], outerRadius)

  points.map (point) -> pointAsString(point)


starPointsLooped = () ->
  points = starPoints()
  points.push(points[0])

  points


drawLinearStar = () ->
  points = starPoints()

  pathString = "M " + points.shift() + " L "
  for point in points
    pathString += point + " "
  pathString += "Z";

  $("#star").attr("d", pathString);

drawQuadraticStar = () ->
  points = starPointsLooped()

  pathString = "M " + points[0]
  for i in [1..10] by 2
    pathString += " Q " + points[i] + " " + points[i + 1]
  pathString += " Z";
  $("#star").attr("d", pathString);

drawCubicStar = () ->
  points = starPointsLooped()

  pathString = "M " + points[0]
  for i in [1..10] by 2
    pathString += " C " + points[i] + " " + points[i] + " " + points[i + 1]
  pathString += " Z";
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


updateInnerRadius = () ->
  $(".rangeslider__handle", $innerRadius.$range).text($innerRadius.val())
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
    onSlide: updateInnerRadius
  }
  $innerRadius.val(0.5).change()
