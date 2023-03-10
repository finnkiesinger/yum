import 'package:flutter/material.dart';
import 'package:yum/constants.dart';

enum HintState {
  initial,
  ideas,
}

class Hint extends StatelessWidget {
  final HintState state;

  const Hint({
    required this.state,
    Key? key,
  }) : super(key: key);

  static const _duration = Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          curve: Curves.easeInOut,
          opacity: state == HintState.initial ? 1 : 0,
          duration: _duration,
          child: AnimatedSlide(
            curve: Curves.easeInOut,
            offset: state == HintState.initial
                ? const Offset(0, 0)
                : const Offset(0, 1),
            duration: _duration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Image.asset('assets/images/sparkle.png'),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tap to Generate',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Color(0xFF646464),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedOpacity(
          curve: Curves.easeInOut,
          opacity: state == HintState.ideas ? 1 : 0,
          duration: _duration,
          child: AnimatedSlide(
            curve: Curves.easeInOut,
            offset: state == HintState.ideas
                ? const Offset(0, 0)
                : const Offset(0, -1),
            duration: _duration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Brainstorming Ideas...',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                    color: orange, //Color(0xFF646464),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
