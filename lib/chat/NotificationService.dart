abstract class NotificationService {
  // Initialize the service
  Future<bool> initialize({
    String? appId,
    bool requestPermission = true,
  });


  // Send notification to specific user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  // Handle when notification is opened
  void setOnNotificationOpened(Function(Map<String, dynamic> payload) handler);

  // Handle foreground notifications
  void setOnForegroundNotification(Function(Map<String, dynamic> payload) handler);

  // Get device token
  Future<String?> getDeviceToken();
}