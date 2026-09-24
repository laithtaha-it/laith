import 'package:flutter/material.dart';

/// Purely decorative, soft blurred gradient blobs used behind hero /
/// section content to give the site a premium, modern feel.
///
/// This widget renders no data and holds no state — it is safe to place
/// behind any section without affecting layout of the content in front
/// of it (it should be used inside a [Stack] with this widget first).
class DecorativeBlobBackground extends StatelessWidget {
  const DecorativeBlobBackground({
    required this.color,
    super.key,
    this.secondaryColor,
  });

  final Color color;
  final Color? secondaryColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: _Blob(color: color.withValues(alpha: 0.16), size: 360),
            ),
            Positioned(
              bottom: -140,
              left: -100,
              child: _Blob(
                color: (secondaryColor ?? color).withValues(alpha: 0.10),
                size: 420,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

/// A small pill-shaped label with a leading pulsing dot, used as a
/// purely visual section marker. Renders whatever [label] text is
/// supplied by the caller — it invents no copy of its own.
class PulsingEyebrowChip extends StatefulWidget {
  const PulsingEyebrowChip({
    required this.label,
    required this.color,
    super.key,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  State<PulsingEyebrowChip> createState() => _PulsingEyebrowChipState();
}

class _PulsingEyebrowChipState extends State<PulsingEyebrowChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.label.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: widget.color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null) ...[
            Icon(widget.icon, size: 14, color: widget.color),
            const SizedBox(width: 8),
          ] else ...[
            FadeTransition(
              opacity: Tween<double>(begin: 0.35, end: 1).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            widget.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
          ),
        ],
      ),
    );
  }
}
