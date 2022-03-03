export function setHeaders (axios) {
  const defaultHeaders = axios.defaults.headers.common
  const headersForRailsApi = {
    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content'),
    'X-Requested-With': 'XMLHttpRequest'
  }
  Object.assign(defaultHeaders, headersForRailsApi)
}
