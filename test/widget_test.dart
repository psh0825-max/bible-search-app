import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bible_search/app.dart';

void main() {
  testWidgets('App boots and shows the greeting screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BibleSearchApp()),
    );
    // 첫 프레임만 그리고 외부 의존성(SQLite, Gemini) 호출은 무시.
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
