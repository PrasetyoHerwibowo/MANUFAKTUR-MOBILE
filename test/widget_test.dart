import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:manufaktur_mobile/main.dart';
import 'package:manufaktur_mobile/providers/app_state.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const ManufakturApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('MANUFAKTUR'), findsWidgets);
  });
}
