import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amr_dokan/app/app.dart';
import 'package:amr_dokan/core/storage/shared_prefs_service.dart';

void main() {
  testWidgets('Amar Dokan App splash smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const AmarDokanApp(),
      ),
    );

    expect(find.byType(AmarDokanApp), findsOneWidget);
  });
}
