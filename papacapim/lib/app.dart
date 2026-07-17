// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'providers/auth_provider.dart';
import 'providers/feed_provider.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

/// Raiz do aplicativo com MultiProvider e configuração de rotas.
class PapacapimApp extends StatelessWidget {
  const PapacapimApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Registra locale pt_BR para o pacote timeago
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
      ],
      child: MaterialApp(
        title: 'Papacapim',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
      ),
    );
  }
}
