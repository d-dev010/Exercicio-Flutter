import 'package:agenda_contatos/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AgendaApp loads and renders smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AgendaApp());
    await tester.pumpAndSettle();

    expect(find.text('Agenda de Contatos'), findsWidgets);
  });
}
