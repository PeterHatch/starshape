/* global URI */

let uri = null

export function initializeOptions() {
  uri = new URI()
  const options = uri.search(true)

  if (options.s === undefined) {
    options.s = 'crossingcubic'
  }
  if (options.fg === undefined) {
    options.fg = 'fddc34'
  }
  if (options.bg === undefined) {
    options.bg = '000000'
  }

  return options
}

export function updateUrlQuery(key, value) {
  uri.search((queryParams) => {
    queryParams[key] = value  // eslint-disable-line no-param-reassign
  })
  history.replaceState(null, '', uri.resource())
}
