import 'package:flutter/material.dart';

class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 350);
  static const Duration extraSlow = Duration(milliseconds: 500);
}

class AppCurves {
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve spring = Curves.elasticOut;
  static const Curve easeOut = Curves.easeOutQuad;
  static const Curve decelerate = Curves.decelerate;
}

class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
    this.duration = AppDurations.fast,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed && widget.onTap != null ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: AppCurves.easeOut,
        child: widget.child,
      ),
    );
  }
}
