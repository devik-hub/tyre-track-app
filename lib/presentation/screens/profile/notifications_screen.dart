import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../domain/providers/notification_provider.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the real-time stream provider
    final notificationStream = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: notificationStream.when(
        data: (notifications) {
           if (notifications.isEmpty) {
              return const Center(child: Text('No active notifications', style: TextStyle(color: Colors.grey)));
           }
           return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isUnread = !notif.isRead;
                
                return GestureDetector(
                   onTap: () {
                      if (isUnread) {
                         ref.read(notificationRepositoryProvider).markAsRead(notif.notifId);
                      }
                   },
                   child: Container(
                      color: isUnread ? AppColors.mrfRed.withOpacity(0.05) : Colors.transparent,
                      child: ListTile(
                         leading: CircleAvatar(
                            backgroundColor: notif.type == 'alert' ? AppColors.mrfOrange.withOpacity(0.2) : AppColors.mrfMidGrey.withOpacity(0.2),
                            child: Icon(notif.type == 'alert' ? Icons.warning : Icons.notifications, 
                                     color: notif.type == 'alert' ? AppColors.mrfOrange : AppColors.mrfMidGrey),
                         ),
                         title: Text(notif.title, style: TextStyle(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal)),
                         subtitle: Text(notif.body),
                         trailing: Text(
                            '${DateTime.now().difference(notif.createdAt).inHours}h ago', 
                            style: const TextStyle(color: Colors.grey, fontSize: 12)
                         ),
                      ),
                   ),
                );
              },
           );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.mrfRed)),
        error: (e, s) => Center(child: Text('Error: $e')),
      )
    );
  }
}
