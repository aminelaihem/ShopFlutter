// lib/src/app/bootstrap.dart
// boot propre. même zone pour tout sinon “Zone mismatch”
// init bindings + web url clean + hive (cache) + firebase, puis runApp

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> bootstrap(Widget app) async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized(); // plugins ok

    if (kIsWeb) usePathUrlStrategy(); // urls sans #

    await Hive.initFlutter(); // cache
    await Hive.openBox('cache');
    await Hive.openBox('cart');

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      Zone.current.handleUncaughtError(details.exception, details.stack ?? StackTrace.empty);
    };

    runApp(app);
  }, (error, stack) {
    debugPrint('zone error: $error\n$stack');
  });
}
