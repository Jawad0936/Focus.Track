# FocusTrackMobile

A React Native Expo mobile client for the Focus Tracker backend.

## Setup

1. Install dependencies:

```bash
cd FocusTrackMobile
npm install
```

2. Start the Expo app:

```bash
npm start
```

3. Update the backend host in `src/api/client.js` and `src/notifications/socket.js`:

```js
const BASE_URL = 'http://YOUR_MACHINE_IP:4000/api/v1';
```

Replace `YOUR_MACHINE_IP` with your local machine IP address.

## Notes

- Open `src/auth/useGoogleAuth.js` and replace the placeholder Google client IDs with your credentials.
- The app expects the backend to support the `/api/v1/auth/google`, `/api/v1/me`, `/api/v1/activities`, and notifications socket endpoints.
