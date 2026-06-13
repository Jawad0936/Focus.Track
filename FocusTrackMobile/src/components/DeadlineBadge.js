import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { differenceInHours, isPast, parseISO } from 'date-fns';
import { colors, fontSize, radius } from '../theme';

export default function DeadlineBadge({ deadline }) {
  if (!deadline) return null;

  const date    = parseISO(deadline);
  const overdue = isPast(date);
  const hours   = Math.abs(differenceInHours(date, new Date()));

  const label = overdue
    ? `Overdue by ${hours}h`
    : hours < 24
      ? `Due in ${hours}h`
      : `Due ${date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}`;

  return (
    <View style={[styles.badge, overdue ? styles.overdue : styles.upcoming]}>
      <Text style={[styles.text, overdue ? styles.overdueText : styles.upcomingText]}>
        {label}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  badge:        { paddingHorizontal: 8, paddingVertical: 2, borderRadius: radius.sm },
  overdue:      { backgroundColor: colors.warnDim, borderWidth: 1, borderColor: 'rgba(255,123,84,0.3)' },
  upcoming:     { backgroundColor: 'rgba(96,165,250,0.1)', borderWidth: 1, borderColor: 'rgba(96,165,250,0.3)' },
  text:         { fontSize: fontSize.xs, fontWeight: '500' },
  overdueText:  { color: colors.warn },
  upcomingText: { color: colors.blue },
});
