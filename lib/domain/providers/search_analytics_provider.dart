import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/search_insight_model.dart';

/// Streams top search queries (last 30 days) aggregated by count
final topSearchQueriesProvider = StreamProvider<List<SearchInsight>>((ref) {
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  return FirebaseFirestore.instance
      .collection('search_logs')
      .where('timestamp', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
      .orderBy('timestamp', descending: true)
      .limit(500)
      .snapshots()
      .map((snap) {
        final Map<String, int> counts = {};
        for (final doc in snap.docs) {
          final q = (doc['query'] as String? ?? '').toLowerCase().trim();
          if (q.isNotEmpty) counts[q] = (counts[q] ?? 0) + 1;
        }
        final list = counts.entries
            .map((e) => SearchInsight(query: e.key, count: e.value, isZeroResult: false))
            .toList()
          ..sort((a, b) => b.count.compareTo(a.count));
        return list.take(20).toList();
      });
});

/// Streams zero-result searches (last 30 days), grouped & sorted by frequency
final zeroResultSearchesProvider = StreamProvider<List<SearchInsight>>((ref) {
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  return FirebaseFirestore.instance
      .collection('search_logs')
      .where('resultsCount', isEqualTo: 0)
      .where('timestamp', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
      .snapshots()
      .map((snap) {
        final Map<String, int> counts = {};
        for (final doc in snap.docs) {
          final q = (doc['query'] as String? ?? '').toLowerCase().trim();
          if (q.isNotEmpty) counts[q] = (counts[q] ?? 0) + 1;
        }
        final list = counts.entries
            .map((e) => SearchInsight(query: e.key, count: e.value, isZeroResult: true))
            .toList()
          ..sort((a, b) => b.count.compareTo(a.count));
        return list.take(20).toList();
      });
});
