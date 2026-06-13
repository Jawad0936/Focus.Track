import React, { useState, useEffect, useCallback } from 'react';
import {
  View, Text, FlatList, StyleSheet,
  RefreshControl, TouchableOpacity, Alert
} from 'react-native';
import { Activities } from '../api/endpoints';
import { useAuth } from '../auth/AuthContext';
import ActivityCard from '../components/ActivityCard';
import { colors, spacing, fontSize, radius } from '../theme';

const FILTERS = [
  { label: 'All',       value: {} },
  { label: 'Pending',   value: { status: 'pending' } },
  { label: 'Done',      value: { status: 'completed' } },
  { label: 'Overdue',   value: { deadline: 'overdue' } },
  { label: 'This week', value: { deadline: 'week' } },
];

export default function ActivityListScreen({ navigation }) {
  const { user, signOut }           = useAuth();
  const [activities, setActivities] = useState([]);
  const [loading, setLoading]       = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [activeFilter, setFilter]   = useState(0);

  const fetchActivities = useCallback(async (filterIndex = activeFilter) => {
    try {
      const { data } = await Activities.list(FILTERS[filterIndex].value);
      setActivities(data);
    } catch (e) {
      Alert.alert('Error', e.message);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }, [activeFilter]);

  useEffect(() => { fetchActivities(); }, [activeFilter]);

  const handleComplete = async (id) => {
    try {
      await Activities.complete(id);
      fetchActivities();
    } catch (e) {
      Alert.alert('Error', e.message);
    }
  };

  const handleFilterChange = (index) => {
    setFilter(index);
    setLoading(true);
    fetchActivities(index);
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <View>
          <Text style={styles.title}>Activities</Text>
          <Text style={styles.subtitle}>Hi, {user?.name?.split(' ')[0]}</Text>
        </View>
        <TouchableOpacity onPress={signOut} style={styles.signOutBtn}>
          <Text style={styles.signOutText}>Sign out</Text>
        </TouchableOpacity>
      </View>

      <FlatList
        horizontal
        data={FILTERS}
        keyExtractor={(_, i) => i.toString()}
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.filterRow}
        renderItem={({ item, index }) => (
          <TouchableOpacity
            style={[styles.chip, activeFilter === index && styles.chipActive]}
            onPress={() => handleFilterChange(index)}
          >
            <Text style={[styles.chipText, activeFilter === index && styles.chipTextActive]}>
              {item.label}
            </Text>
          </TouchableOpacity>
        )}
      />

      {loading ? (
        <View style={styles.center}>
          <Text style={styles.loadingText}>Loading...</Text>
        </View>
      ) : (
        <FlatList
          data={activities}
          keyExtractor={item => item.id}
          contentContainerStyle={styles.list}
          showsVerticalScrollIndicator={false}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={() => { setRefreshing(true); fetchActivities(); }}
              tintColor={colors.accent}
            />
          }
          ListEmptyComponent={
            <View style={styles.empty}>
              <Text style={styles.emptyText}>No activities found.</Text>
              <Text style={styles.emptyNote}>Create some on the web app.</Text>
            </View>
          }
          renderItem={({ item }) => (
            <ActivityCard
              activity={item}
              onComplete={handleComplete}
              onPress={() => navigation.navigate('ActivityDetail', { activity: item })}
            />
          )}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container:       { flex: 1, backgroundColor: colors.bg },
  header:          { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', paddingHorizontal: spacing.lg, paddingTop: 60, paddingBottom: spacing.md },
  title:           { fontSize: fontSize.xl, fontWeight: '700', color: colors.text },
  subtitle:        { fontSize: fontSize.sm, color: colors.muted, marginTop: 2 },
  signOutBtn:      { paddingHorizontal: spacing.sm, paddingVertical: spacing.xs, borderWidth: 0.5, borderColor: colors.border2, borderRadius: radius.sm },
  signOutText:     { color: colors.muted, fontSize: fontSize.xs },
  filterRow:       { paddingHorizontal: spacing.lg, gap: spacing.sm, paddingBottom: spacing.md },
  chip:            { paddingHorizontal: 14, paddingVertical: 6, borderRadius: 20, borderWidth: 0.5, borderColor: colors.border2, backgroundColor: colors.surface },
  chipActive:      { backgroundColor: colors.accentDim, borderColor: 'rgba(200,240,96,0.3)' },
  chipText:        { color: colors.muted, fontSize: fontSize.sm },
  chipTextActive:  { color: colors.accent },
  list:            { paddingHorizontal: spacing.lg, paddingBottom: 100 },
  center:          { flex: 1, alignItems: 'center', justifyContent: 'center' },
  loadingText:     { color: colors.muted, fontSize: fontSize.sm },
  empty:           { alignItems: 'center', paddingTop: 80 },
  emptyText:       { color: colors.muted, fontSize: fontSize.base },
  emptyNote:       { color: colors.muted, fontSize: fontSize.sm, marginTop: 4 },
});
