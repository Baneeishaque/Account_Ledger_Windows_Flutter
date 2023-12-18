import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'env/env.dart';

Future<String?> getGistData() async {
  const MethodChannel methodChannel =
      MethodChannel('samples.flutter.io/battery');
  String? result;
  try {
    result = await methodChannel.invokeMethod<String>(
      'getGistData',
      {
        "USERNAME": Env.username,
        "GITHUB_ACCESS_TOKEN": Env.gitHubAccessToken,
        "GIST_ID": Env.gistId,
      },
    );
    debugPrint(result);
  } on PlatformException catch (e) {
    debugPrint('Error - ${e.message}');
  }
  return result;
}
