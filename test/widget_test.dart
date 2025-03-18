import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bitsphere/screens/product_list_screen.dart';

void main() {
  testWidgets('Upload button shows dialog', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ProductListScreen()));
    expect(find.byIcon(Icons.add), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text("Upload Product"), findsOneWidget);
  });

  testWidgets('SnackBar shows on empty fields', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ProductListScreen()));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.text("Add"));
    await tester.pumpAndSettle();
    expect(find.text("Fill all fields!"), findsOneWidget);
  });

  testWidgets('Valid input adds product', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ProductListScreen()));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, "Name"), "New Code");
    await tester.enterText(find.widgetWithText(TextField, "Price"), "\$20");
    await tester.enterText(find.widgetWithText(TextField, "Description"), "Cool stuff");
    await tester.tap(find.text("Add"));
    await tester.pumpAndSettle();

    expect(find.text("New Code"), findsOneWidget);
  });
}