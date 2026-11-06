import 'package:flutter/material.dart';
import 'animation_utils.dart';

class FadeSlideSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Offset beginOffset;

  const FadeSlideSwitcher({
    super.key,
    required this.child,
    this.duration = AppDurations.normal,
    this.beginOffset = const Offset(0.0, 0.05),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AppCurves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final offsetAnimation = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
