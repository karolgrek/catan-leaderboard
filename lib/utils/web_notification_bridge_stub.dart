Future<String> requestNotificationPermissionImpl() async {
  return 'unsupported';
}

String getNotificationPermissionImpl() {
  return 'unsupported';
}

Future<void> showSystemNotificationImpl({
  required String title,
  required String body,
  required String tag,
}) async {
  // No-op on non-web platforms unless native plugin is added
}
