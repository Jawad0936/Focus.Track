import React, { useState, useEffect } from 'react';
import { View, Text, FlatList, StyleSheet } from 'react-native';
import { format, parseISO } from 'date-fns';
import { addNotificationListener } from '../notifications/socket';
import { colors, spacing, radius, fontSize } from '../theme';

export default function NotificationsScreen() {
  const [notifications, setNotifications] = useState([]);

  useEffect(() => {
    const unsubscribe = addNotificationListener((notif) => {
      setNotifications(prev => [notif, ...prev].slice(0, 50));
    });
    return unsubscribe;
  }, []);

  const renderItem = ({ item }) => (
    <View style={styles.item}>
      <View style={[styles.typeBadge, item.type === 'overdue' ? styles.overdue : styles.upcoming]}>
        <Text style={[styles.typeText, item.type === 'overdue' ? styles.overdueText : styles.upcomingText]}>
          {item.type}
        </Text>
      </View>
      <Text style={styles.message}>{item.message}</Text>
      <Text style={styles.time}>
        {item.sent_at ? format(parseISO(item.sent_at), 'MMM d · HH:mm') : 'just now'}
      </Text>
    </View>
  );

  return (
    <View style={styles.container}>
      <Text style={styles.header}>Notifications</Text>
      <FlatList
        data={notifications}
        keyExtractor={(item, i) => item.id || i.toString()}
        contentContainerStyle={styles.list}
        ListEmptyComponent={
          <View style={styles.empty}>
            <Text style={styles.emptyText}>No notifications yet.</Text>
            <Text style={styles.emptyNote}>
              You'll be alerted here for upcoming and overdue activities.
            </Text>
          </View>
        }
        renderItem={renderItem}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container:    { flex: 1, backgroundColor: colors.bg },
  header:       { fontSize: fontSize.xl, fontWeight: '700', color: colors.text, paddingHorizontal: spacing.lg, paddingTop: 60, paddingBottom: spacing.md },
  list:         { paddingHorizontal: spacing.lg, paddingBottom: 100 },
  item:         { backgroundColor: colors.surface, borderWidth: 0.5, borderColor: colors.border, borderRadius: radius.lg, padding: spacing.md, marginBottom: spacing.sm },
  typeBadge:    { alignSelf: 'flex-start', paddingHorizontal: 8, paddingVertical: 2, borderRadius: 4, marginBottom: spacing.sm },
  overdue:      { backgroundColor: colors.warnDim, borderWidth: 1, borderColor: 'rgba(255,123,84,0.3)' },
  upcoming:     { backgroundColor: 'rgba(96,165,250,0.1)', borderWidth: 1, borderColor: 'rgba(96,165,250,0.3)' },
  typeText:     { fontSize: fontSize.xs, fontWeight: '500', textTransform: 'capitalize' },
  overdueText:  { color: colors.warn },
  upcomingText: { color: colors.blue },
  message:      { color: colors.text, fontSize: fontSize.md, lineHeight: 20, marginBottom: 6 },
  time:         { color: colors.muted, fontSize: fontSize.xs },
  empty:        { alignItems: 'center', paddingTop: 80 },
  emptyText:    { color: colors.muted, fontSize: fontSize.base, marginBottom: 6 },
  emptyNote:    { color: colors.muted, fontSize: fontSize.sm, textAlign: 'center', lineHeight: 18 },
});
