if (!('URLSearchParams' in window)) {
  const script = document.createElement('script')
  script.src = 'https://cdnjs.cloudflare.com/ajax/libs/url-search-params/0.10.0/url-search-params.js'
  document.head.appendChild(script)
}
