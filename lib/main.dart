import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'controllers/app_state.dart';
import 'controllers/app_state_provider.dart';
import 'routes/app_routes.dart';

/// PONTO DE ENTRADA DO APLICATIVO PAPACAPIM
/// Inicializa o estado global `AppState`, provê o `AppStateProvider` para toda
/// a árvore de widgets e configura o tema e o sistema de rotas. 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Instancia a camada de estado local contendo os dados mockados
  final appState = AppState();

  runApp(PapacapimApp(appState: appState));
}

class PapacapimApp extends StatelessWidget {
  final AppState appState;

  const PapacapimApp({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return AppStateProvider(
      state: appState,
      child: MaterialApp(
        title: 'Papacapim',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.landing,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
