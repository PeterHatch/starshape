function hexFromRGB(r, g, b) {
  var hex = [
    r.toString( 16 ),
    g.toString( 16 ),
    b.toString( 16 )
  ];
  $.each( hex, function( nr, val ) {
    if ( val.length === 1 ) {
      hex[ nr ] = "0" + val;
    }
  });
  return hex.join( "" ).toUpperCase();
}
function refreshForeground() {
  var red = $( "#red-fg" ).slider( "value" ),
    green = $( "#green-fg" ).slider( "value" ),
    blue = $( "#blue-fg" ).slider( "value" ),
    hex = hexFromRGB( red, green, blue );
  $( "#swatch" ).css( "color", "#" + hex );
}
function refreshBackground() {
  var red = $( "#red-bg" ).slider( "value" ),
    green = $( "#green-bg" ).slider( "value" ),
    blue = $( "#blue-bg" ).slider( "value" ),
    hex = hexFromRGB( red, green, blue );
  $( "#swatch" ).css( "background-color", "#" + hex );
}

function polarToCartesian(angle, distance) {
  x = Math.cos(angle) * distance;
  y = Math.sin(angle) * distance;
  return {x: x, y: y}
}

function pointAsString(point) {
  return "" + point.x + "," + point.y;
}

function refreshStarPath() {
  var innerRadius = $( "#inner-radius" ).slider( "value") / 1000.0;
  var outerRadius = 1;
  var innerAngles = [-7*Math.PI/10, -3*Math.PI/10,   Math.PI/10, 5*Math.PI/10,  9*Math.PI/10]
  var outerAngles = [-5*Math.PI/10,   -Math.PI/10, 3*Math.PI/10, 7*Math.PI/10, -9*Math.PI/10]
  var innerPoints = innerAngles.map(function(angle) {
    return polarToCartesian(angle, innerRadius);
  });
  var outerPoints = outerAngles.map(function(angle) {
    return polarToCartesian(angle, outerRadius);
  });


  var pathString = "M " + pointAsString(innerPoints[0]);
  for (i = 0; i < innerPoints.length - 1; i++) {
    pathString += " C " + pointAsString(outerPoints[i]) + " " + pointAsString(outerPoints[i]) + " " + pointAsString(innerPoints[i + 1]);
  }
  pathString += " C " + pointAsString(outerPoints[4]) + " " + pointAsString(outerPoints[4]) + " " + pointAsString(innerPoints[0]) + " Z";
  $( "#star" ).attr("d", pathString);
}

$( document ).ready(function() {
  $( "#red-fg, #green-fg, #blue-fg, #red-bg, #green-bg, #blue-bg" ).slider({
    orientation: "horizontal",
    range: "min",
    max: 255,
    value: 127
  });
  $( "#red-fg, #green-fg, #blue-fg" ).slider({
    slide: refreshForeground,
    change: refreshForeground
  });
  $( "#red-bg, #green-bg, #blue-bg" ).slider({
    slide: refreshBackground,
    change: refreshBackground
  });
  $( "#red-fg" ).slider( "value", 253 );
  $( "#green-fg" ).slider( "value", 220 );
  $( "#blue-fg" ).slider( "value", 52 );
  $( "#red-bg, #green-bg, #blue-bg" ).slider( "value", 0 );
  $( "#inner-radius" ).slider({
    orientation: "horizontal",
    range: "min",
    max: 1000,
    value: 500,
    slide: refreshStarPath,
    change: refreshStarPath
  });
  $( "#inner-radius" ).slider( "value", 500 );
});
