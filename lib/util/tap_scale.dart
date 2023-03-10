import 'package:flutter/material.dart';

class TapScale extends StatefulWidget {
  final Widget child;
  final Function()? onTap;
  final Function()? onTapDown;
  final Function()? onTapEnd;
  final bool scale;

  const TapScale({
    Key? key,
    required this.child,
    this.onTapDown,
    this.onTapEnd,
    this.onTap,
    this.scale = true,
  }) : super(key: key);

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) {
        widget.onTapDown?.call();
        setState(() {
          _pressed = true;
        });
      },
      onTapUp: (_) {
        widget.onTapEnd?.call();
        setState(() {
          _pressed = false;
        });
      },
      onTapCancel: () {
        widget.onTapEnd?.call();
        setState(() {
          _pressed = false;
        });
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        curve: Curves.easeInOut,
        duration: const Duration(milliseconds: 150),
        scale: (_pressed && widget.scale) ? 0.95 : 1,
        child: widget.child,
      ),
    );
  }
}
