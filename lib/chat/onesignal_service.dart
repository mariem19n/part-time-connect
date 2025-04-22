import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'NotificationService.dart';

class OneSignalService implements NotificationService {
  @override
  Future<bool> initialize({String? appId, bool requestPermission = true}) async {
    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(appId ?? '803e5057-effd-41b5-83de-b473198ceeba');
      if (requestPermission) {
        await OneSignal.Notifications.requestPermission(true);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  @override
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Notifications to users by ID are typically sent via backend/server.
    // This is a placeholder.
  }

  @override
  void setOnNotificationOpened(Function(Map<String, dynamic>) handler) {
    OneSignal.Notifications.addClickListener((event) {
      handler(event.notification.additionalData ?? {});
    });
  }

  @override
  void setOnForegroundNotification(Function(Map<String, dynamic>) handler) {
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      handler(event.notification.additionalData ?? {});
      event.preventDefault(); // Prevent default system notification
      event.notification.display(); // Manually display it if needed
    });
  }

  @override
  Future<String?> getDeviceToken() async {
    final subscription = OneSignal.User.pushSubscription;

    if (subscription.optedIn == true) {
      return subscription.id;
    }

    return null;
  }
}
