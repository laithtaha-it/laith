import 'dart:async';

import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

bool _visibilityDetectorConfigured = false;

void _configureVisibilityDetector() {
  if (_visibilityDetectorConfigured) return;

  // The package batches visibility callbacks. 50ms keeps fast touch/wheel
  // scrolling responsive without attaching a per-frame scroll listener.
  VisibilityDetectorController.instance.updateInterval =
      const Duration(milliseconds: 50);

  _visibilityDetectorConfigured = true;
}

/// UI-only scroll entrance animation primitives.
///
/// These widgets do not access or modify application state, BLoCs, Cubits,
/// repositories, models, navigation, or API layers. They only animate [child].
class ScrollRevealWrapper extends StatefulWidget {
  const ScrollRevealWrapper({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 480),
    this.offset = 40,
    this.triggerFraction = 0.20,
    this.reset = false,
  });

  final Widget child;
  final Duration duration;
  final double offset;
  final double triggerFraction;
  final bool reset;

  @override
  State<ScrollRevealWrapper> createState() => _ScrollRevealWrapperState();
}

class _ScrollRevealWrapperState extends State<ScrollRevealWrapper>
    with SingleTickerProviderStateMixin {
  static const Curve _curve = Cubic(0.645, 0.045, 0.355, 1.0);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: _curve,
  );

  late Animation<double> _offsetY = _buildOffsetAnimation();

  final Key _visibilityKey = UniqueKey();
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _configureVisibilityDetector();
  }

  Animation<double> _buildOffsetAnimation() {
    return Tween<double>(
      begin: widget.offset,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: _curve));
  }

  @override
  void didUpdateWidget(covariant ScrollRevealWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    if (oldWidget.offset != widget.offset) {
      _offsetY = _buildOffsetAnimation();
    }

    if (widget.reset && !oldWidget.reset) {
      _revealed = false;
      _controller.reset();
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;

    if (widget.reset) {
      final shouldReveal = info.visibleFraction >= widget.triggerFraction;

      if (shouldReveal && !_revealed) {
        _revealed = true;
        _controller.forward(from: 0);
      } else if (!shouldReveal && _revealed) {
        _revealed = false;
        _controller.reverse();
      }
      return;
    }

    if (!_revealed && info.visibleFraction >= widget.triggerFraction) {
      _revealed = true;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _handleVisibilityChanged,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          child: widget.child,
          builder: (context, child) {
            return Opacity(
              opacity: _opacity.value,
              child: Transform.translate(
                offset: Offset(0, _offsetY.value),
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Reveals a group when its parent first enters the viewport.
///
/// The group trigger uses any visible portion (> 0) because requiring 20% of
/// a very tall list to be visible would delay the animation unnecessarily.
class StaggeredScrollList extends StatefulWidget {
  const StaggeredScrollList({
    required this.children,
    super.key,
    this.duration = const Duration(milliseconds: 480),
    this.offset = 40,
    this.delayStep = const Duration(milliseconds: 100),
    this.reset = false,
  });

  final List<Widget> children;
  final Duration duration;
  final double offset;
  final Duration delayStep;
  final bool reset;

  @override
  State<StaggeredScrollList> createState() => _StaggeredScrollListState();
}

class _StaggeredScrollListState extends State<StaggeredScrollList> {
  final Key _visibilityKey = UniqueKey();
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _configureVisibilityDetector();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;

    final visible = info.visibleFraction > 0;

    if (widget.reset) {
      if (visible != _revealed) {
        setState(() => _revealed = visible);
      }
      return;
    }

    if (visible && !_revealed) {
      setState(() => _revealed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: _handleVisibilityChanged,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < widget.children.length; i++)
            StaggeredScrollItem(
              index: i,
              revealed: _revealed,
              duration: widget.duration,
              offset: widget.offset,
              delay: widget.delayStep * i,
              reset: widget.reset,
              child: widget.children[i],
            ),
        ],
      ),
    );
  }
}

/// Animation primitive used by [StaggeredScrollList].
class StaggeredScrollItem extends StatefulWidget {
  const StaggeredScrollItem({
    required this.child,
    required this.index,
    required this.revealed,
    super.key,
    this.duration = const Duration(milliseconds: 480),
    this.offset = 40,
    this.delay = Duration.zero,
    this.reset = false,
  });

  final Widget child;
  final int index;
  final bool revealed;
  final Duration duration;
  final double offset;
  final Duration delay;
  final bool reset;

  @override
  State<StaggeredScrollItem> createState() => _StaggeredScrollItemState();
}

class _StaggeredScrollItemState extends State<StaggeredScrollItem>
    with SingleTickerProviderStateMixin {
  static const Curve _curve = Cubic(0.645, 0.045, 0.355, 1.0);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: _curve,
  );

  late Animation<double> _offsetY = _buildOffsetAnimation();

  Timer? _delayTimer;
  bool _started = false;

  Animation<double> _buildOffsetAnimation() {
    return Tween<double>(
      begin: widget.offset,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: _curve));
  }

  @override
  void initState() {
    super.initState();

    if (widget.revealed) {
      _scheduleReveal();
    }
  }

  @override
  void didUpdateWidget(covariant StaggeredScrollItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    if (oldWidget.offset != widget.offset) {
      _offsetY = _buildOffsetAnimation();
    }

    if (widget.reset && !oldWidget.reset) {
      _cancelReveal();
      _started = false;
      _controller.reset();
    }

    if (widget.revealed && !oldWidget.revealed) {
      _scheduleReveal();
    } else if (widget.reset && !widget.revealed && oldWidget.revealed) {
      _cancelReveal();
      _started = false;
      _controller.reverse();
    }
  }

  void _scheduleReveal() {
    if (_started || !mounted) return;

    _cancelReveal();

    if (widget.delay == Duration.zero) {
      _startReveal();
      return;
    }

    _delayTimer = Timer(widget.delay, () {
      if (mounted) {
        _startReveal();
      }
    });
  }

  void _startReveal() {
    if (_started || !mounted) return;

    _started = true;
    _controller.forward();
  }

  void _cancelReveal() {
    _delayTimer?.cancel();
    _delayTimer = null;
  }

  @override
  void dispose() {
    _cancelReveal();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          return Opacity(
            opacity: _opacity.value,
            child: Transform.translate(
              offset: Offset(0, _offsetY.value),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
