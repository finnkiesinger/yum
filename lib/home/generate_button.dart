import 'package:flutter/material.dart';
import 'package:yum/constants.dart';

import '../util/tap_scale.dart';

class GenerateButton extends StatefulWidget {
  final Function()? onTapDown;
  final Function()? onTapEnd;
  final Function()? onTap;

  const GenerateButton({
    this.onTapDown,
    this.onTapEnd,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<GenerateButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TapScale(
      onTap: widget.onTap,
      onTapDown: () {
        widget.onTapDown?.call();
        _controller.stop(canceled: false);
      },
      onTapEnd: () {
        widget.onTapEnd?.call();
        _controller.repeat(reverse: true);
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 + _animation.value * 0.05,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: orange,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: orange.withOpacity(0.5),
                    spreadRadius: 4,
                    blurRadius: 20,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: 125,
                  height: 125,
                  child: Image.asset(
                    'assets/images/lightning.png',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
