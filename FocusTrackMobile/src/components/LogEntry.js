import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { format, parseISO } from 'date-fns';
import { colors, spacing, radius, fontSize } from '../theme';

export default function LogEntry({ log }) {
  return (
    <View style={[styles.entry, log.system && styles.systemEntry]}>
      {log.system && <Text style={styles.systemIcon}>⚙</Text>}
      <View style={styles.content}>
        <Text style={[styles.description, log.system && styles.systemText]}>
          {log.description}
        </Text>
        <Text style={styles.timestamp}>
          {format(parseISO(log.inserted_at), 'MMM d, yyyy · HH:mm')}
        </Text>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  entry: {
    backgroundColor: colors.surface,
    borderWidth: 0.5,
    borderColor: colors.border,
    borderRadius: radius.md,
    padding: spacing.md,
    marginBottom: spacing.sm,
    flexDirection: 'row',
    gap: spacing.sm,
  },
  systemEntry: {
    borderStyle: 'dashed',
    backgroundColor: colors.surface2,
  },
  systemIcon: { color: colors.muted, fontSize: fontSize.sm, marginTop: 1 },
  content: { flex: 1 },
  description: { color: colors.text, fontSize: fontSize.md, lineHeight: 20 },
  systemText: { color: colors.muted, fontStyle: 'italic' },
  timestamp: { color: colors.muted, fontSize: fontSize.xs, marginTop: 4 },
});
