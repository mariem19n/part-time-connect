// chat/notification_handler.dart
import 'notification_payload.dart';
import 'package:flutter/material.dart';

class NotificationHandler {
  final GlobalKey<NavigatorState> navigatorKey;

  NotificationHandler({required this.navigatorKey});

  void handleNotification(Map<String, dynamic> payload) {
    final notification = NotificationPayload.fromMap(payload);
    final context = navigatorKey.currentContext;
    if (context == null) return;

    switch (notification.type) {
      case NotificationType.newMessage:
        _handleNewMessage(notification, context);
        break;
      case NotificationType.jobApplication:
        _handleJobApplication(notification, context);
        break;
    }
  }

  void _handleNewMessage(NotificationPayload payload, BuildContext context) {
    Navigator.of(context).pushNamed(
      '/chat',
      arguments: {
        'receiverId': payload.senderId,
        'receiverType': payload.senderType,
      },
    );
  }

  void _handleJobApplication(NotificationPayload payload, BuildContext context) {
    Navigator.of(context).pushNamed(
      '/application',
      arguments: {'applicationId': payload.data['application_id']},
    );
  }
}