// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/app/bootstrap.dart';
import 'src/app/app.dart';

Future<void> main() async {
  // ProviderScope ici pour que tout l’arbre y ait accès.
  await bootstrap(const ProviderScope(child: App()));
}
