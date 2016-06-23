import URLSearchParams from 'url-search-params'

let params = null

export function initializeOptions() {
  params = new URLSearchParams(location.search.slice(1))

  const options = {}
  for (const [key, value] of params.entries()) {
    options[key] = value
  }
  return options
}

export function addOption(key, value) {
  params.set(key, value)
}

export function removeOption(key) {
  params.delete(key)
}

export function updateUrlQuery(key, value) {
  addOption(key, value)
  history.replaceState(null, '', `${location.pathname}?${params}`)
}
