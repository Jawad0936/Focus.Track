import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors, fontSize, radius } from '../theme';

export default function StatusBadge({ status }) {
  const isPending = status === 'pending';
  return (
    <View style={[styles.badge, isPending ? styles.pending : styles.completed]}>
      <Text style={[styles.text, isPending ? styles.pendingText : styles.completedText]}>
        {status}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  badge:         { paddingHorizontal: 8, paddingVertical: 2, borderRadius: radius.sm },
  pending:       { backgroundColor: 'rgba(251,191,36,0.15)', borderWidth: 1, borderColor: 'rgba(251,191,36,0.3)' },
  completed:     { backgroundColor: 'rgba(74,222,128,0.15)', borderWidth: 1, borderColor: 'rgba(74,222,128,0.3)' },
  text:          { fontSize: fontSize.xs, fontWeight: '500', textTransform: 'capitalize' },
  pendingText:   { color: '#fbbf24' },
  completedText: { color: colors.green },
});
