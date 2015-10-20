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


refreshStarPath = () ->
  innerRadius = $("#inner-radius").slider("value") / 1000.0
  outerRadius = 1;
  innerAngles = [-7*Math.PI/10, -3*Math.PI/10,   Math.PI/10, 5*Math.PI/10,  9*Math.PI/10]
  outerAngles = [-5*Math.PI/10,   -Math.PI/10, 3*Math.PI/10, 7*Math.PI/10, -9*Math.PI/10]
  innerPoints = innerAngles.map (angle) -> polarToCartesian(angle, innerRadius)
  outerPoints = outerAngles.map (angle) -> polarToCartesian(angle, outerRadius)

  pathString = "M " + pointAsString(innerPoints[0])
  for i in [0...4]
    pathString += " C " + pointAsString(outerPoints[i]) + " " + pointAsString(outerPoints[i]) + " " + pointAsString(innerPoints[i + 1]);
  pathString += " C " + pointAsString(outerPoints[4]) + " " + pointAsString(outerPoints[4]) + " " + pointAsString(innerPoints[0]) + " Z";
  $("#star").attr("d", pathString);


$(document).ready () ->
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

  $("#inner-radius").slider {
    orientation: "horizontal"
    range: "min"
    max: 1000
    value: 500
    slide: refreshStarPath
    change: refreshStarPath
  }
  $("#inner-radius").slider("value", 500)
