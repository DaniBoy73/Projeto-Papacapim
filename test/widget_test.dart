import 'package:flutter_test/flutter_test.dart';
import 'package:projeto_papacapim/main.dart';
import 'package:projeto_papacapim/controllers/app_state.dart';

void main() {
  testWidgets('Papacapim App smoke test', (WidgetTester tester) async {
    final appState = AppState();
    await tester.pumpWidget(PapacapimApp(appState: appState));

    // Verifica se a tela inicial exibe a marca Papacapim
    expect(find.text('Papacapim'), findsOneWidget);
  });
}
