enum NotificationType { newMessage, jobApplication }

class NotificationPayload {
  final NotificationType type;
  final String senderId;
  final String senderType;
  final Map<String, dynamic> data;

  NotificationPayload({
    required this.type,
    required this.senderId,
    required this.senderType,
    this.data = const {},
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      type: map['type'] == 'job_application'
          ? NotificationType.jobApplication
          : NotificationType.newMessage,
      senderId: map['sender_id'] ?? '',
      senderType: map['sender_type'] ?? 'user',
      data: map['data'] ?? {},
    );
  }
}