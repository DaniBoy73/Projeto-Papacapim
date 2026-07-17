// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:papacapim/app.dart';

void main() {
  testWidgets('App inicializa na tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const PapacapimApp());
    await tester.pumpAndSettle();
    expect(find.text('Entrar na conta'), findsOneWidget);
  });
}
