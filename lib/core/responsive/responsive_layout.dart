import 'package:flutter/material.dart';

import '../../app/theme/app_breakpoints.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    super.key,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < AppBreakpoints.mobile) {
      return mobile;
    }

    if (width < AppBreakpoints.tablet) {
      return tablet ?? mobile;
    }

    return desktop ?? tablet ?? mobile;
  }
}
