import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hedieaty_app/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Log in and navigate through app', (WidgetTester tester) async {
    // Start the app
    app.main();
    await tester.pumpAndSettle();

    // Log in
    await tester.tap(find.byKey(Key('loginButton')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(Key('emailField')), 'local2@yahoo.com');
    await tester.enterText(find.byKey(Key('passwordField')), '123456');
    await tester.tap(find.byKey(Key('login')));
    await tester.pumpAndSettle();

    // Navigate to 'View Events'
    await tester.tap(find.text('viewEvents'));
    await tester.pumpAndSettle();

    // Navigate to 'View gift list' of event 'test'
    await tester.tap(find.byKey(Key('viewGifts')));
    await tester.pumpAndSettle();

    // Pledge to a gift
    await tester.tap(find.byKey(Key('pledge')));
    await tester.pumpAndSettle();

    // Back navigation
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Navigate to 'MyProfile'
    await tester.tap(find.byTooltip('View Profile'));
    await tester.pumpAndSettle();

    // Navigate to 'Pledged Gifts'
    await tester.tap(find.text('pledged gifts'));
    await tester.pumpAndSettle();
  });
}
