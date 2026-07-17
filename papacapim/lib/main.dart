// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Força orientação retrato
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configura a cor da status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PapacapimApp());
}
