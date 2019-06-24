import 'dart:async';

import 'package:flutter/services.dart';

class Zimageviewer {
  static const MethodChannel _channel =
      const MethodChannel('co.izeta.dev/zimageviewer');

  static Future<bool> displayImageviewer(List<String> photos, List<String> captions, int startIndex) async {
    final String result = await _channel.invokeMethod('displayImageViewer', {'photos': photos, 
      'captions': captions, 'start_position': startIndex });

    return result == 'SUCCESS'; 
  }
}
