import 'package:cloud_firestore/cloud_firestore.dart';

class SearchInsight {
  final String query;
  final int count;
  final bool isZeroResult;

  SearchInsight({required this.query, required this.count, required this.isZeroResult});
}

class SearchLogEntry {
  final String query;
  final String userId;
  final int resultsCount;
  final List<String> resultIds;

  SearchLogEntry({
    required this.query,
    required this.userId,
    required this.resultsCount,
    required this.resultIds,
  });

  Map<String, dynamic> toMap() => {
    'query':        query,
    'userId':       userId,
    'timestamp':    FieldValue.serverTimestamp(),
    'resultsCount': resultsCount,
    'resultIds':    resultIds,
  };
}
