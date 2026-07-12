import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_ventures_link/shared/widgets/section_card.dart';

void main() {
  testWidgets('SectionCard renders long titles without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 150,
            child: SectionCard(
              title:
                  'This is a very long section title that should wrap without overflowing',
              child: const SizedBox(height: 20),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
