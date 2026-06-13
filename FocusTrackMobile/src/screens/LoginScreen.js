import React, { useEffect } from 'react';
import {
  View, Text, TouchableOpacity,
  StyleSheet, ActivityIndicator
} from 'react-native';
import { useGoogleAuth } from '../auth/useGoogleAuth';
import { useAuth } from '../auth/AuthContext';
import { colors, spacing, radius, fontSize } from '../theme';

export default function LoginScreen() {
  const { signIn }               = useAuth();
  const { request, response, promptAsync } = useGoogleAuth();
  const [loading, setLoading]    = React.useState(false);
  const [error, setError]        = React.useState(null);

  useEffect(() => {
    if (response?.type === 'success') {
      const { id_token } = response.params;
      handleSignIn(id_token);
    }
  }, [response]);

  const handleSignIn = async (idToken) => {
    setLoading(true);
    setError(null);
    try {
      await signIn(idToken);
    } catch (e) {
      setError('Sign in failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.card}>
        <View style={styles.logoRow}>
          <Text style={styles.logo}>focus</Text>
          <Text style={styles.logoDim}>.track</Text>
        </View>
        <Text style={styles.subtitle}>
          Sign in to view and manage your activities
        </Text>

        {error && (
          <View style={styles.errorBox}>
            <Text style={styles.errorText}>{error}</Text>
          </View>
        )}

        <TouchableOpacity
          style={[styles.googleBtn, (!request || loading) && styles.disabled]}
          onPress={() => promptAsync()}
          disabled={!request || loading}
        >
          {loading ? (
            <ActivityIndicator color="#1a1a1a" />
          ) : (
            <>
              <Text style={styles.googleIcon}>G</Text>
              <Text style={styles.googleText}>Continue with Google</Text>
            </>
          )}
        </TouchableOpacity>

        <Text style={styles.note}>
          Use the same Google account as your web app
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.bg,
    alignItems: 'center',
    justifyContent: 'center',
    padding: spacing.lg,
  },
  card: {
    backgroundColor: colors.surface,
    borderWidth: 0.5,
    borderColor: colors.border2,
    borderRadius: radius.lg,
    padding: spacing.xl,
    width: '100%',
    maxWidth: 360,
    alignItems: 'center',
  },
  logoRow:    { flexDirection: 'row', alignItems: 'baseline', marginBottom: spacing.sm },
  logo:       { fontSize: fontSize.xl, fontWeight: '700', color: colors.accent },
  logoDim:    { fontSize: fontSize.xl, fontWeight: '300', color: colors.muted },
  subtitle:   { color: colors.muted, fontSize: fontSize.sm, textAlign: 'center', marginBottom: spacing.lg },
  errorBox:   { backgroundColor: colors.warnDim, borderRadius: radius.sm, padding: spacing.sm, marginBottom: spacing.md, width: '100%' },
  errorText:  { color: colors.warn, fontSize: fontSize.sm, textAlign: 'center' },
  googleBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing.sm,
    backgroundColor: '#ffffff',
    borderRadius: radius.md,
    paddingVertical: 12,
    paddingHorizontal: spacing.lg,
    width: '100%',
    marginBottom: spacing.md,
  },
  disabled:    { opacity: 0.5 },
  googleIcon:  { fontSize: fontSize.lg, fontWeight: '700', color: '#4285F4' },
  googleText:  { fontSize: fontSize.md, fontWeight: '600', color: '#1a1a1a' },
  note:        { color: colors.muted, fontSize: fontSize.xs, textAlign: 'center' },
});
