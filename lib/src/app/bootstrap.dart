// lib/src/app/bootstrap.dart
// Boot de l’app. J’initialise Firebase, j’ajuste 2-3 détails Web,
// je câble une zone pour capter les erreurs async, puis je lance runApp.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart'; // généré par `flutterfire configure`
import 'package:flutter_web_plugins/url_strategy.dart'; // URLs Web sans # (optionnel)

Future<void> bootstrap(Widget app) async {
  // Nécessaire avant d’utiliser des plugins (Firebase, etc.)
  WidgetsFlutterBinding.ensureInitialized();

  // Web : URLs propres (pas de #). Sans effet hors Web.
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  // Firebase : init avec les options générées (multi-plateformes).
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Redirige les erreurs Flutter vers la zone (lisible en debug, plug Crashlytics plus tard si besoin).
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Zone.current.handleUncaughtError(
      details.exception,
      details.stack ?? StackTrace.empty,
    );
  };

  // Zone pour intercepter les erreurs asynchrones non catchées.
  runZonedGuarded<void>(
        () => runApp(app),
        (error, stack) {
      debugPrint('Uncaught zone error: $error\n$stack');
    },
  );
}
