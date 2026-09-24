/// Consistent spacing scale for the whole app.
///
/// Every gap, padding and margin in the redesigned UI should come from this
/// scale instead of an arbitrary number. That is what keeps the vertical
/// rhythm and visual density consistent across Hero, sections, cards and the
/// admin dashboard.
abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
  static const double xxxxl = 96;

  /// Standard gap between an eyebrow/label and the heading that follows it.
  static const double labelToHeading = 14;

  /// Standard gap between a section heading and its body content.
  static const double headingToBody = 24;

  /// Vertical padding applied to a full page section (mobile).
  static const double sectionPaddingMobile = 72;

  /// Vertical padding applied to a full page section (desktop/tablet).
  static const double sectionPaddingDesktop = 120;
}
