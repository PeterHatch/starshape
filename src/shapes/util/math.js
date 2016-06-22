import zip from 'lodash.zip'

class Point {
  constructor(x, y) {
    this.x = x
    this.y = y
  }

  toString() {
    return `${this.x},${this.y}`
  }
}

export function polarToCartesian(angle, distance) {
  const x = Math.cos(angle) * distance
  const y = Math.sin(angle) * distance
  return new Point(x, y)
}

export function addPoints([point1, point2]) {
  return new Point(point1.x + point2.x, point1.y + point2.y)
}

function calculateDistance(point1, point2) {
  return Math.sqrt(Math.pow(point1.x - point2.x, 2) + Math.pow(point1.y - point2.y, 2))
}

function calculateAngle(point1, point2) {
  return Math.atan2(point2.y - point1.y, point2.x - point1.x)
}


// a is an intermediate point, b an outer point, and c another intermediate point.
//
// This currently relies on the line AC being horizontal (to simplify calculation of angle CAB).
//
// M is the midpoint of AC, and X is the center of the circle with radius R we are solving for.
export function calculateRadius(a, b, c) {
  const angleCAB = calculateAngle(a, b)
  const angleCAX = angleCAB + (Math.PI / 2)
  const lengthAM = calculateDistance(a, c) / 2

  return lengthAM * (1 / Math.cos(angleCAX))
}


export function calculateInnerPoints(radius) {
  const innerAngles = [-7 * Math.PI / 10, -3 * Math.PI / 10, Math.PI / 10, 5 * Math.PI / 10, 9 * Math.PI / 10]
  return innerAngles.map((angle) => polarToCartesian(angle, radius))
}

export function getOuterAngles() {
  return [-5 * Math.PI / 10, -Math.PI / 10, 3 * Math.PI / 10, 7 * Math.PI / 10, -9 * Math.PI / 10]
}

export function calculateOuterPoints(radius = 1) {
  return getOuterAngles().map((angle) => polarToCartesian(angle, radius))
}

// This functions calculates the points in between each set of inner and outer points.
// If there are five points in each, there will be five in the output.
function calculateSimpleIntermediatePoints(innerPoints, outerPoints, percentage) {
  const fullDistance = calculateDistance(innerPoints[0], outerPoints[0])
  const straightDistance = (percentage / 100) * fullDistance
  const angles = zip(innerPoints, outerPoints).map(([innerPoint, outerPoint]) => calculateAngle(innerPoint, outerPoint))

  const displacementVectors = angles.map((angle) => polarToCartesian(angle, straightDistance))
  return zip(innerPoints, displacementVectors).map(addPoints)
}

export function calculateIntermediatePoints(innerPoints1, innerPoints2, outerPoints, percentage) {
  const points1 = calculateSimpleIntermediatePoints(innerPoints1, outerPoints, percentage)
  const points2 = calculateSimpleIntermediatePoints(innerPoints2, outerPoints, percentage)

  return [points1, points2]
}

export function calculateIntermediatePointsComingAndGoing(innerPoints, outerPoints, percentage) {
  const shiftedInnerPoints = innerPoints.slice(1)
  shiftedInnerPoints.push(innerPoints[0])
  return calculateIntermediatePoints(innerPoints, shiftedInnerPoints, outerPoints, percentage)
}
