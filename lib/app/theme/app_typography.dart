import 'package:flutter/widgets.dart';

import '../../core/responsive/responsive.dart';

/// Central typography scale for the public portfolio.
///
/// # Philosophy
///
/// The "premium" feeling in this design comes from composition, spacing and
/// hierarchy — not from oversized type. Every size below is deliberately
/// moderate. If a section feels empty, fix it with layout/whitespace, not by
/// bumping a number here.
///
/// # Arabic vs English optical balance
///
/// Tajawal reads visually larger than Inter at the same numeric size, so
/// Arabic sizes are nudged down slightly (see [_arabicScale]) to keep AR and
/// EN feeling like the same design rather than two different scales.
abstract final class AppTypography {
  const AppTypography._();

  static bool _isArabic(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  static double _scaled(BuildContext context, double size) {
    return _isArabic(context) ? size * 0.94 : size;
  }

  /// Hero headline. Desktop 50–56, tablet 42–46, mobile 30–34.
  static double hero(BuildContext context) {
    final double base;
    if (Responsive.isMobile(context)) {
      base = 32;
    } else if (Responsive.isTablet(context)) {
      base = 44;
    } else if (Responsive.isLargeDesktop(context)) {
      base = 56;
    } else {
      base = 50;
    }
    return _scaled(context, base);
  }

  /// Section headings ("Projects", "Skills", "Contact", ...).
  static double sectionHeading(BuildContext context) {
    final double base;
    if (Responsive.isMobile(context)) {
      base = 26;
    } else if (Responsive.isTablet(context)) {
      base = 30;
    } else {
      base = 36;
    }
    return _scaled(context, base);
  }

  /// Project / case-study titles.
  static double projectTitle(BuildContext context) {
    final double base;
    if (Responsive.isMobile(context)) {
      base = 23;
    } else if (Responsive.isTablet(context)) {
      base = 27;
    } else {
      base = 32;
    }
    return _scaled(context, base);
  }

  /// Eyebrow / role line above the Hero heading and section intros.
  static double subheading(BuildContext context) {
    final double base;
    if (Responsive.isMobile(context)) {
      base = 18;
    } else if (Responsive.isTablet(context)) {
      base = 19;
    } else {
      base = 20;
    }
    return _scaled(context, base);
  }

  /// Body copy.
  static double body(BuildContext context) {
    final base = Responsive.isMobile(context) ? 15.0 : 16.0;
    return _scaled(context, base);
  }

  /// Metadata / small labels (project number, tech tags, dates).
  static double meta(BuildContext context) {
    final base = Responsive.isMobile(context) ? 12.0 : 13.0;
    return _scaled(context, base);
  }

  /// Navbar links. Deliberately quiet — must never compete with the Hero.
  static const double navItem = 14;

  /// Button labels.
  static const double button = 14;

  /// Line height multiplier for body copy. Arabic gets slightly more
  /// breathing room so Tajawal doesn't feel compressed.
  static double bodyLineHeight(BuildContext context) =>
      _isArabic(context) ? 1.85 : 1.7;

  /// Line height multiplier for headings.
  static double headingLineHeight(BuildContext context) =>
      _isArabic(context) ? 1.35 : 1.12;
}
