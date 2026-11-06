import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'animation_utils.dart';

CustomTransitionPage<T> buildFadeSlidePage<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.normal,
    reverseTransitionDuration: AppDurations.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: AppCurves.easeOut),
      );
      final slideIn = Tween<Offset>(
        begin: const Offset(0.04, 0.0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: animation, curve: AppCurves.easeOut),
      );

      return FadeTransition(
        opacity: fadeIn,
        child: SlideTransition(
          position: slideIn,
          child: child,
        ),
      );
    },
  );
}
