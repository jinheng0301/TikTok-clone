import 'package:flutter/material.dart';

class LikeAnimation extends StatefulWidget {
  late final Widget child;
  late final bool isAnimating;
  final Duration duration;
  late final VoidCallback? onEnd;
  final bool smallLike;

  LikeAnimation({
    required this.child,
    required this.isAnimating,
    this.duration = const Duration(milliseconds: 150),
    this.onEnd,
    this.smallLike = false,
  });

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    scale = Tween<double>(begin: 1, end: 1.2).animate(controller);
  }

  @override
  void didUpdateWidget(covariant LikeAnimation oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      startAnimation();
    }
  }

  Future<void> startAnimation() async {
    if (widget.isAnimating || widget.smallLike) {
      await controller.forward();
      await controller.reverse();
      await Future.delayed(Duration(microseconds: 200));
      if (widget.onEnd != null) {
        widget.onEnd!();
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: widget.child,
    );
  }
}
