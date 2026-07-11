import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: CampusVenturesLinkApp(),
    ),
  );
}

class CampusVenturesLinkApp extends ConsumerWidget {
  const CampusVenturesLinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Campus Ventures Link',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        // Keep AppColors in sync with whatever brightness MaterialApp
        // actually resolved (system OR an explicit manual override from
        // the Appearance setting), not just the raw OS brightness.
        AppColors.syncBrightness(Theme.of(context).brightness);
        return child!;
      },
      routerConfig: router,
    );
  }
}
