import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campus_ventures_link/core/constants/firestore_constants.dart';
import 'package:campus_ventures_link/features/auth/presentation/controllers/auth_controller.dart';
import 'package:campus_ventures_link/features/opportunity/presentation/controllers/opportunity_controller.dart';
import 'package:campus_ventures_link/features/profile/presentation/screens/student_dashboard_screen.dart';
import 'package:campus_ventures_link/main.dart';
import 'package:campus_ventures_link/shared/models/app_user.dart';

void main() {
  testWidgets('App loads with splash branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: CampusVenturesLinkApp()),
    );

    expect(find.text('Campus Ventures Link'), findsOneWidget);
  });

  testWidgets('Student dashboard fits in a small viewport without overflow', (
    WidgetTester tester,
  ) async {
    const testUser = AppUser(
      uid: 'test-uid',
      name: 'Amina Hassan',
      email: 'amina@alustudent.com',
      role: UserRoles.student,
      skills: [],
      onboardingCompleted: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAppUserProvider.overrideWith((ref) => Stream.value(testUser)),
          opportunitiesProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MaterialApp(
          home: SizedBox(
            width: 320,
            height: 600,
            child: StudentDashboardScreen(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Hello, Amina'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
