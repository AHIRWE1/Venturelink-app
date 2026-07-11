import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePrefsKey = 'campus_ventures_link.theme_mode';

/// Persisted light/dark/system preference. Defaults to [ThemeMode.system]
/// and loads any saved override asynchronously right after — the app
/// briefly follows the OS theme on cold start until that finishes, which
/// is unnoticeable in practice and avoids needing an async splash gate
/// just for this.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadSaved();
    return ThemeMode.system;
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeModePrefsKey);
    if (saved == null) return;
    state = ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModePrefsKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
