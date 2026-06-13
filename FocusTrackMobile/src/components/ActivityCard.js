import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, Alert } from 'react-native';
import { colors, spacing, radius, fontSize } from '../theme';
import StatusBadge from './StatusBadge';
import DeadlineBadge from './DeadlineBadge';

export default function ActivityCard({ activity, onPress, onComplete }) {
  const isPending = activity.status === 'pending';

  const handleComplete = () => {
    Alert.alert(
      'Mark as Complete',
      `Mark "${activity.description}" as complete?`,
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Complete', onPress: () => onComplete(activity.id) },
      ]
    );
  };

  return (
    <TouchableOpacity style={styles.card} onPress={onPress} activeOpacity={0.7}>
      <View style={styles.top}>
        <TouchableOpacity
          style={[styles.circle, !isPending && styles.circleChecked]}
          onPress={isPending ? handleComplete : null}
          disabled={!isPending}
        >
          {!isPending && <Text style={styles.checkmark}>✓</Text>}
        </TouchableOpacity>

        <View style={styles.content}>
          <Text
            style={[styles.description, !isPending && styles.descriptionDone]}
            numberOfLines={2}
          >
            {activity.description}
          </Text>

          <View style={styles.badges}>
            <View style={styles.categoryBadge}>
              <Text style={styles.categoryText}>{activity.category}</Text>
            </View>
            <StatusBadge status={activity.status} />
            <DeadlineBadge deadline={activity.deadline} />
          </View>
        </View>
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.surface,
    borderWidth: 0.5,
    borderColor: colors.border,
    borderRadius: radius.lg,
    padding: spacing.md,
    marginBottom: spacing.sm,
  },
  top: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    gap: spacing.md,
  },
  circle: {
    width: 22,
    height: 22,
    borderRadius: 11,
    borderWidth: 1.5,
    borderColor: colors.border2,
    marginTop: 2,
    alignItems: 'center',
    justifyContent: 'center',
    flexShrink: 0,
  },
  circleChecked: {
    backgroundColor: colors.green,
    borderColor: colors.green,
  },
  checkmark: { color: '#0e0e10', fontSize: 12, fontWeight: '700' },
  content: { flex: 1 },
  description: { color: colors.text, fontSize: fontSize.base, fontWeight: '500', marginBottom: spacing.sm },
  descriptionDone: { textDecorationLine: 'line-through', color: colors.muted },
  badges: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.xs },
  categoryBadge: {
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 4,
    backgroundColor: colors.surface2,
    borderWidth: 0.5,
    borderColor: colors.border2,
  },
  categoryText: { color: colors.muted, fontSize: fontSize.xs, textTransform: 'capitalize' },
});
