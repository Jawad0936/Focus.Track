import React, { useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createStackNavigator } from '@react-navigation/stack';
import { Text, View } from 'react-native';

import { AuthProvider, useAuth } from './src/auth/AuthContext';
import { connectNotifications, disconnectNotifications } from './src/notifications/socket';

import LoginScreen          from './src/screens/LoginScreen';
import ActivityListScreen   from './src/screens/ActivityListScreen';
import ActivityDetailScreen from './src/screens/ActivityDetailScreen';
import NotificationsScreen  from './src/screens/NotificationsScreen';

import { colors } from './src/theme';

const Tab   = createBottomTabNavigator();
const Stack = createStackNavigator();

function ActivitiesStack() {
  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle:      { backgroundColor: colors.surface },
        headerTintColor:  colors.text,
        headerTitleStyle: { fontWeight: '600' },
      }}
    >
      <Stack.Screen
        name="ActivityList"
        component={ActivityListScreen}
        options={{ headerShown: false }}
      />
      <Stack.Screen
        name="ActivityDetail"
        component={ActivityDetailScreen}
        options={({ route }) => ({
          title: 'Activity',
          headerBackTitle: 'Back',
        })}
      />
    </Stack.Navigator>
  );
}

function AppTabs() {
  const { token } = useAuth();

  useEffect(() => {
    if (token) {
      connectNotifications();
    }
    return () => disconnectNotifications();
  }, [token]);

  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: { backgroundColor: colors.surface, borderTopColor: colors.border },
        tabBarActiveTintColor: colors.accent,
        tabBarInactiveTintColor: colors.muted,
      }}
    >
      <Tab.Screen
        name="Activities"
        component={ActivitiesStack}
        options={{
          tabBarIcon: ({ color }) => <Text style={{ color, fontSize: 20 }}>📋</Text>,
        }}
      />
      <Tab.Screen
        name="Notifications"
        component={NotificationsScreen}
        options={{
          tabBarIcon: ({ color }) => <Text style={{ color, fontSize: 20 }}>🔔</Text>,
        }}
      />
    </Tab.Navigator>
  );
}

function RootNavigator() {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <View style={{ flex: 1, backgroundColor: colors.bg, alignItems: 'center', justifyContent: 'center' }}>
        <Text style={{ color: colors.accent, fontSize: 18 }}>focus.track</Text>
      </View>
    );
  }

  return user ? <AppTabs /> : <LoginScreen />;
}

export default function App() {
  return (
    <AuthProvider>
      <NavigationContainer
        theme={{
          colors: {
            background:   colors.bg,
            card:         colors.surface,
            text:         colors.text,
            border:       colors.border,
            notification: colors.accent,
            primary:      colors.accent,
          }
        }}
      >
        <RootNavigator />
      </NavigationContainer>
    </AuthProvider>
  );
}
