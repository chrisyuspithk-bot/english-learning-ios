const BASE = '/api'

export function getToken() {
  return localStorage.getItem('portal_token')
}

export function setToken(token) {
  localStorage.setItem('portal_token', token)
}

export function clearToken() {
  localStorage.removeItem('portal_token')
}

async function request(method, path, body) {
  const headers = {}
  const token = getToken()
  if (token) headers['Authorization'] = 'Bearer ' + token
  if (body !== undefined) headers['Content-Type'] = 'application/json'

  const res = await fetch(BASE + path, {
    method,
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  })

  if (res.status === 401) {
    clearToken()
    window.location.reload()
    throw new Error('Session expired')
  }

  const text = await res.text()
  const data = text ? JSON.parse(text) : null
  if (!res.ok) {
    throw new Error(data?.detail || 'Request failed')
  }
  return data
}

export const api = {
  get: (path) => request('GET', path),
  post: (path, body) => request('POST', path, body),
  put: (path, body) => request('PUT', path, body),
  del: (path) => request('DELETE', path),
}

// Upload with multipart (for textbook files / CSV import).
export async function upload(path, formData) {
  const token = getToken()
  const res = await fetch(BASE + path, {
    method: 'POST',
    headers: token ? { Authorization: 'Bearer ' + token } : {},
    body: formData,
  })
  const text = await res.text()
  const data = text ? JSON.parse(text) : null
  if (!res.ok) throw new Error(data?.detail || 'Upload failed')
  return data
}
