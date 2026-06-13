import React, { createContext, useContext, useState, useEffect } from 'react';
import * as SecureStore from 'expo-secure-store';
import { Auth } from '../api/endpoints';

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser]       = useState(null);
  const [token, setToken]     = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      try {
        const saved = await SecureStore.getItemAsync('auth_token');
        if (saved) {
          setToken(saved);
          const { data } = await Auth.me();
          setUser(data);
        }
      } catch {
        await SecureStore.deleteItemAsync('auth_token');
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const signIn = async (googleToken) => {
    const result = await Auth.loginWithGoogle(googleToken);
    await SecureStore.setItemAsync('auth_token', result.token);
    setToken(result.token);

    const { data } = await Auth.me();
    setUser(data);
    return result;
  };

  const signOut = async () => {
    await SecureStore.deleteItemAsync('auth_token');
    setToken(null);
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, token, loading, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
