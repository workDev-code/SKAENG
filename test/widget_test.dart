import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke — Flutter test binding works', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Scan & Learn English'))),
      ),
    );
    expect(find.text('Scan & Learn English'), findsOneWidget);
  });
}
