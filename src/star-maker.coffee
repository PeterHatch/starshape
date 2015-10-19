hexFromRGB = (r, g, b) ->
  hex = [
    r.toString(16)
    g.toString(16)
    b.toString(16)
  ]
  $.each(hex, (nr, val) ->
    if val.length == 1
      hex[nr] = "0" + val
  )
  hex.join("").toUpperCase()


refreshForeground = () ->
  red = $("#red-fg").slider("value")
  green = $("#green-fg").slider("value")
  blue = $("#blue-fg").slider("value")

  hex = hexFromRGB(red, green, blue)

  $("#swatch").css("color", "#" + hex)


refreshBackground = () ->
  red = $("#red-bg").slider("value")
  green = $("#green-bg").slider("value")
  blue = $("#blue-bg").slider("value")

  hex = hexFromRGB(red, green, blue)

  $("#swatch").css("background-color", "#" + hex)


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
  $("#red-fg, #green-fg, #blue-fg, #red-bg, #green-bg, #blue-bg").slider {
    orientation: "horizontal"
    range: "min"
    max: 255
    value: 127
  }
  $("#red-fg, #green-fg, #blue-fg").slider {
    slide: refreshForeground
    change: refreshForeground
  }
  $("#red-bg, #green-bg, #blue-bg").slider {
    slide: refreshBackground,
    change: refreshBackground
  }
  $("#red-fg").slider("value", 253)
  $("#green-fg").slider("value", 220)
  $("#blue-fg").slider("value", 52)
  $("#red-bg, #green-bg, #blue-bg").slider("value", 0)
  $("#inner-radius").slider {
    orientation: "horizontal"
    range: "min"
    max: 1000
    value: 500
    slide: refreshStarPath
    change: refreshStarPath
  }
  $("#inner-radius").slider("value", 500)
