import 'package:flutter/material.dart';

import '../../app/theme/app_breakpoints.dart';

class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    required this.child,
    super.key,
    this.maxWidth = 1200,
    this.mobilePadding = 20,
    this.tabletPadding = 32,
    this.desktopPadding = 48,
  });

  final Widget child;
  final double maxWidth;
  final double mobilePadding;
  final double tabletPadding;
  final double desktopPadding;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    final horizontalPadding = switch (width) {
      < AppBreakpoints.mobile => mobilePadding,
      < AppBreakpoints.tablet => tabletPadding,
      _ => desktopPadding,
    };

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }
}
