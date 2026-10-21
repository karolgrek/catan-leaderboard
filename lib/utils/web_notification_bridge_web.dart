import 'dart:js_interop';

@JS('getCatanNotificationPermission')
external JSString _getCatanNotificationPermission();

@JS('requestCatanNotificationPermission')
external JSPromise<JSString> _requestCatanNotificationPermission();

@JS('showCatanNotification')
external JSPromise<JSBoolean> _showCatanNotification(
  JSString title,
  JSString body,
  JSString tag,
);

String getNotificationPermissionImpl() {
  try {
    return _getCatanNotificationPermission().toDart;
  } catch (_) {
    return 'unsupported';
  }
}

Future<String> requestNotificationPermissionImpl() async {
  try {
    final JSString result = await _requestCatanNotificationPermission().toDart;
    return result.toDart;
  } catch (_) {
    return 'denied';
  }
}

Future<void> showSystemNotificationImpl({
  required String title,
  required String body,
  required String tag,
}) async {
  try {
    await _showCatanNotification(title.toJS, body.toJS, tag.toJS).toDart;
  } catch (_) {
    // Ignore errors if browser blocks notification
  }
}
