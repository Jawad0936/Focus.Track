import * as SecureStore from 'expo-secure-store';

const BASE_URL = 'http://YOUR_MACHINE_IP:4000/api/v1';

async function getToken() {
  return await SecureStore.getItemAsync('auth_token');
}

async function request(method, path, body = null) {
  const token = await getToken();

  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };

  const response = await fetch(`${BASE_URL}${path}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : null,
  });

  const data = await response.json();

  if (!response.ok) {
    throw new Error(data.error || 'Request failed');
  }

  return data;
}

export const api = {
  get:    (path)         => request('GET',    path),
  post:   (path, body)   => request('POST',   path, body),
  put:    (path, body)   => request('PUT',     path, body),
  delete: (path)         => request('DELETE',  path),
};
