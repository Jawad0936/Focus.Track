import { api } from './client';

export const Auth = {
  loginWithGoogle: (googleToken) =>
    api.post('/auth/google', { google_token: googleToken }),
  me: () => api.get('/me'),
};

export const Activities = {
  list:     (filters = {}) => {
    const params = new URLSearchParams(filters).toString();
    return api.get(`/activities${params ? '?' + params : ''}`);
  },
  show:     (id) => api.get(`/activities/${id}`),
  complete: (id) => api.put(`/activities/${id}/complete`),
};

export const Logs = {
  list: (activityId) => api.get(`/activities/${activityId}/logs`),
};
