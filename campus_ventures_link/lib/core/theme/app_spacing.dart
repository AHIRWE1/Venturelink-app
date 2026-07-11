/// Shared spacing scale so every screen uses the same rhythm instead of
/// picking ad-hoc numbers. `screenPadding` in particular is the one that
/// matters most visually — it's the horizontal inset used by every
/// top-level screen's scrollable content, so switching tabs doesn't shift
/// where content lines up against the screen edge.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Standard horizontal inset for top-level screen content.
  static const double screenPadding = xl;
}
