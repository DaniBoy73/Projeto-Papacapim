import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_papacapim/main.dart';
import 'package:projeto_papacapim/controllers/app_state.dart';
import 'package:projeto_papacapim/controllers/app_state_provider.dart';
import 'package:projeto_papacapim/screens/profile_screen.dart';

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('Papacapim App smoke test', (WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(PapacapimApp(appState: appState));

    // Verifica se a tela inicial exibe a marca Papacapim
    expect(find.text('Papacapim'), findsOneWidget);
  });

  testWidgets('Follow button changes instantly between Seguir and Seguindo on profile', (WidgetTester tester) async {
    final appState = AppState();
    final targetUser = appState.getUserByLogin('juliana_tech');

    // Suprime exceções de imagem de rede no ambiente de teste
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is NetworkImageLoadException) return;
      FlutterError.presentError(details);
    };

    await tester.pumpWidget(
      MaterialApp(
        home: AppStateProvider(
          state: appState,
          child: ProfileScreen(targetUser: targetUser),
        ),
      ),
    );

    // Inicialmente não segue a Juliana Tech, botão de elevação deve mostrar 'Seguir'
    final followButtonFinder = find.widgetWithText(ElevatedButton, 'Seguir');
    final followingButtonFinder = find.widgetWithText(ElevatedButton, 'Seguindo');

    expect(followButtonFinder, findsOneWidget);
    expect(followingButtonFinder, findsNothing);

    // Clica no botão de Seguir
    await tester.tap(followButtonFinder);
    await tester.pump();

    // Deve mudar imediatamente para 'Seguindo' no botão
    expect(find.widgetWithText(ElevatedButton, 'Seguindo'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Seguir'), findsNothing);
  });
}
