import React, { useState, useEffect } from 'react';
import {
  View, Text, StyleSheet, TouchableOpacity, Alert, ScrollView
} from 'react-native';
import { format, parseISO } from 'date-fns';
import { Activities, Logs } from '../api/endpoints';
import LogEntry from '../components/LogEntry';
import StatusBadge from '../components/StatusBadge';
import DeadlineBadge from '../components/DeadlineBadge';
import { colors, spacing, radius, fontSize } from '../theme';

export default function ActivityDetailScreen({ route, navigation }) {
  const { activity: initial } = route.params;
  const [activity, setActivity] = useState(initial);
  const [logs, setLogs] = useState([]);
  const [logsLoading, setLogsLoading] = useState(true);

  useEffect(() => {
    fetchLogs();
  }, []);

  const fetchLogs = async () => {
    try {
      const { data } = await Logs.list(activity.id);
      setLogs(data);
    } catch (e) {
      Alert.alert('Error', 'Could not load logs.');
    } finally {
      setLogsLoading(false);
    }
  };

  const handleComplete = () => {
    Alert.alert(
      'Mark as Complete',
      `Mark "${activity.description}" as complete?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Complete',
          onPress: async () => {
            try {
              const { data } = await Activities.complete(activity.id);
              setActivity(data);
              navigation.setParams({ activity: data });
            } catch (e) {
              Alert.alert('Error', e.message);
            }
          }
        }
      ]
    );
  };

  const formatDt = (iso) => {
    if (!iso) return '—';
    return format(parseISO(iso), 'MMM d, yyyy · HH:mm');
  };

  return (
    <View style={styles.container}>
      <ScrollView showsVerticalScrollIndicator={false}>
        <View style={styles.activityCard}>
          <View style={styles.badgeRow}>
            <View style={styles.categoryBadge}>
              <Text style={styles.categoryText}>{activity.category}</Text>
            </View>
            <StatusBadge status={activity.status} />
            <DeadlineBadge deadline={activity.deadline} />
          </View>
          <Text style={[styles.description, activity.status === 'completed' && styles.descriptionDone]}>
            {activity.description}
          </Text>
          <View style={styles.metaGrid}>
            <View style={styles.metaItem}>
              <Text style={styles.metaLabel}>Created</Text>
              <Text style={styles.metaValue}>{formatDt(activity.inserted_at)}</Text>
            </View>
            <View style={styles.metaItem}>
              <Text style={styles.metaLabel}>Updated</Text>
              <Text style={styles.metaValue}>{formatDt(activity.updated_at)}</Text>
            </View>
            {activity.deadline && (
              <View style={styles.metaItem}>
                <Text style={styles.metaLabel}>Deadline</Text>
                <Text style={styles.metaValue}>{formatDt(activity.deadline)}</Text>
              </View>
            )}
            {activity.completed_at && (
              <View style={styles.metaItem}>
                <Text style={styles.metaLabel}>Completed</Text>
                <Text style={[styles.metaValue, { color: colors.green }]}>
                  {formatDt(activity.completed_at)}
                </Text>
              </View>
            )}
          </View>
          {activity.status === 'pending' && (
            <TouchableOpacity style={styles.completeBtn} onPress={handleComplete}>
              <Text style={styles.completeBtnText}>Mark complete ✓</Text>
            </TouchableOpacity>
          )}
        </View>

        <View style={styles.logsSection}>
          <Text style={styles.logsTitle}>
            Logs <Text style={styles.logCount}>({logs.length})</Text>
          </Text>
          <Text style={styles.readOnlyNote}>
            View only — create logs on the web app
          </Text>
          {logsLoading ? (
            <Text style={styles.loadingText}>Loading logs...</Text>
          ) : logs.length === 0 ? (
            <View style={styles.emptyLogs}>
              <Text style={styles.emptyText}>No logs yet.</Text>
            </View>
          ) : (
            logs.map(log => <LogEntry key={log.id} log={log} />)
          )}
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container:      { flex: 1, backgroundColor: colors.bg },
  activityCard:   { backgroundColor: colors.surface, borderBottomWidth: 0.5, borderColor: colors.border, padding: spacing.lg, paddingTop: spacing.xl },
  badgeRow:       { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.xs, marginBottom: spacing.md },
  categoryBadge:  { paddingHorizontal: 8, paddingVertical: 2, borderRadius: 4, backgroundColor: colors.surface2, borderWidth: 0.5, borderColor: colors.border2 },
  categoryText:   { color: colors.muted, fontSize: fontSize.xs, textTransform: 'capitalize' },
  description:    { fontSize: fontSize.lg, fontWeight: '600', color: colors.text, lineHeight: 26, marginBottom: spacing.lg },
  descriptionDone: { textDecorationLine: 'line-through', color: colors.muted },
  metaGrid:       { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.md, marginBottom: spacing.lg },
  metaItem:       { minWidth: '45%' },
  metaLabel:      { fontSize: fontSize.xs, color: colors.muted, marginBottom: 2 },
  metaValue:      { fontSize: fontSize.sm, color: colors.text },
  completeBtn:    { backgroundColor: '#16a34a', borderRadius: radius.md, paddingVertical: 12, alignItems: 'center' },
  completeBtnText: { color: '#ffffff', fontSize: fontSize.md, fontWeight: '600' },
  logsSection:    { padding: spacing.lg, paddingBottom: 100 },
  logsTitle:      { fontSize: fontSize.base, fontWeight: '600', color: colors.text, marginBottom: 4 },
  logCount:       { color: colors.muted, fontWeight: '400' },
  readOnlyNote:   { fontSize: fontSize.xs, color: colors.muted, marginBottom: spacing.md },
  loadingText:    { color: colors.muted, fontSize: fontSize.sm },
  emptyLogs:      { alignItems: 'center', paddingVertical: 40 },
  emptyText:      { color: colors.muted, fontSize: fontSize.sm },
});
