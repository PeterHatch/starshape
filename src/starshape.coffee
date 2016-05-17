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
  updateUrlQuery("s", "circular")
  refreshStarPath()

setShapeToQuadratic = () ->
  drawStarFunction = drawStarWithQuadraticTips
  updateUrlQuery("s", "quadratic")
  refreshStarPath()

setShapeToCubic = () ->
  drawStarFunction = drawStarWithCubicTips
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
