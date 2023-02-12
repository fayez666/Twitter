import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:twitter/common/common.dart';
import 'package:twitter/features/auth/controller/auth_controller.dart';
import 'package:twitter/features/notificaions/controller/notification_controller.dart';
import 'package:twitter/features/notificaions/widgets/notification_tile.dart';

import '../../../constants/constants.dart';
import '../../../models/notification_model.dart';

class NotificationView extends ConsumerWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: currentUser == null
          ? const Loader()
          : ref.watch(getNotificationsProvider(currentUser.uId)).when(
                data: (notifications) {
                  return ref.watch(getLatestNotificationProvider).when(
                    data: (data) {
                      if (data.events.contains(
                        'databases.*.collections.${AppwriteConstants.notificationsCollection}.documents.*.create',
                      )) {
                        final latestNotif =
                            NotificationModel.fromMap(data.payload);
                        if (latestNotif.uid == currentUser.uId) {
                          notifications.insert(0, latestNotif);
                        }
                      }

                      return ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (BuildContext context, int index) {
                          final notification = notifications[index];
                          return NotificationTile(notification: notification);
                        },
                      );
                    },
                    error: (error, stackTrace) {
                      return ErrorText(
                        error: error.toString(),
                      );
                    },
                    loading: () {
                      return ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (BuildContext context, int index) {
                          final notification = notifications[index];
                          return NotificationTile(notification: notification);
                        },
                      );
                    },
                  );
                },
                error: (error, stackTrace) {
                  return ErrorText(
                    error: error.toString(),
                  );
                },
                loading: () => const Loader(),
              ),
    );
  }
}
