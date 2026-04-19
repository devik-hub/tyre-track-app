import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import 'auth_provider.dart';

// Use a StreamProvider for real-time notification syncing from Firestore
final notificationProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userId = ref.watch(authProvider).userModel?.uid;
  final repo = ref.watch(notificationRepositoryProvider);
  
  if (userId == null) {
    return Stream.value([]);
  }
  
  return repo.watchUserNotifications(userId);
});
