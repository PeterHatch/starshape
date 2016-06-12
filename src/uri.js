import URI from 'urijs'

let uri = null

export function initializeOptions() {
  uri = new URI()
  return uri.search(true)
}

export function updateUrlQuery(key, value) {
  uri.search((queryParams) => {
    queryParams[key] = value  // eslint-disable-line no-param-reassign
  })
  history.replaceState(null, '', uri.resource())
}
