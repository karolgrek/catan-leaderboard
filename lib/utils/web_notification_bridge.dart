import 'web_notification_bridge_stub.dart'
    if (dart.library.js_interop) 'web_notification_bridge_web.dart';

class WebNotificationBridge {
  static String getPermissionStatus() {
    return getNotificationPermissionImpl();
  }

  static Future<String> requestPermission() {
    return requestNotificationPermissionImpl();
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    required String tag,
  }) {
    return showSystemNotificationImpl(
      title: title,
      body: body,
      tag: tag,
    );
  }
}
