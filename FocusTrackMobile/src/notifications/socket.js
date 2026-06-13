import { Socket } from '@phoenix/channels';
import * as SecureStore from 'expo-secure-store';

let socket = null;
let channel = null;
let listeners = [];

export async function connectNotifications() {
  const token = await SecureStore.getItemAsync('auth_token');
  if (!token) return;

  socket = new Socket('ws://YOUR_MACHINE_IP:4000/socket', {
    params: { token }
  });

  socket.connect();

  channel = socket.channel('notifications:me', { token });

  channel.on('new_notification', (payload) => {
    listeners.forEach(fn => fn(payload));
  });

  channel
    .join()
    .receive('ok', ()    => console.log('[Socket] Joined notifications channel'))
    .receive('error', (e) => console.warn('[Socket] Failed to join:', e));
}

export function addNotificationListener(fn) {
  listeners.push(fn);
  return () => {
    listeners = listeners.filter(l => l !== fn);
  };
}

export function disconnectNotifications() {
  channel?.leave();
  socket?.disconnect();
  socket = null;
  channel = null;
  listeners = [];
}
