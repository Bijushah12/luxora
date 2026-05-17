import 'package:flutter/services.dart';

class ShareService {
  static const _channel = MethodChannel('luxora/share');

  const ShareService._();

  static Future<bool> shareText({
    required String title,
    required String text,
  }) async {
    try {
      await _channel.invokeMethod<void>('shareText', {
        'title': title,
        'text': text,
      });
      return true;
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: text));
      return false;
    }
  }
}
