import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../models/dot_data.dart';

class DotLayer extends StatefulWidget {
  final int horizontal;
  final int vertical;
  final DotController controller;
  final bool animate;

  const DotLayer({
    required this.horizontal,
    required this.vertical,
    required this.controller,
    this.animate = true,
    Key? key,
  }) : super(key: key);

  @override
  State<DotLayer> createState() => _DotLayerState();
}

class _DotLayerState extends State<DotLayer>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  double _width = 0;
  double _height = 0;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  DotController? _dotController;

  final List<DotData> _dots = [];

  late Size _size;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      _dotController?.clear();
      for (var i = 0; i < 5; i++) {
        _dotController?.addGravity(_size);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _size = MediaQuery.of(context).size;
      _width = _size.width / widget.horizontal;
      _height = _size.height / widget.vertical;
      var random = Random();
      for (var i = 0; i < 2 * widget.horizontal; i++) {
        for (var j = 0; j < 2 * widget.vertical; j++) {
          _dots.add(
            DotData(
              position: Point(
                -(widget.horizontal / 2) * _width + i * _width + _width / 2 - 2,
                -(widget.vertical / 2) * _height +
                    j * _height +
                    _height / 2 -
                    2,
              ),
              offset: Offset.zero,
              animationOffset: random.nextDouble(),
            ),
          );
        }
      }

      _dotController = widget.controller;

      setState(() {});
    });
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.repeat(reverse: true);
  }

  var _lastElapsedDuration = Duration.zero;

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _dotController?.addWave(details.globalPosition);
      },
      child: Container(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            var delta = ((_controller.lastElapsedDuration ?? Duration.zero) -
                        _lastElapsedDuration)
                    .inMilliseconds /
                1000.0;
            _lastElapsedDuration =
                _controller.lastElapsedDuration ?? Duration.zero;
            if (widget.animate) {
              _dotController?.updateGravity(delta, _size);
              _dotController?.updateWaves(delta);
              for (var dot in _dots) {
                dot.offset = _dotController?.calculateOffset(dot.position) ??
                    Offset.zero;
              }
            }
            return Stack(
              children: [
                for (var dot in _dots)
                  Dot(
                    position: dot.position,
                    offset: dot.offset,
                    value: _animation.value,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final Point position;
  final double value;
  final Offset offset;

  const Dot({
    required this.position,
    required this.value,
    required this.offset,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.y.toDouble(),
      left: position.x.toDouble(),
      child: Transform.translate(
        offset: offset + offset * 0.03 * sin(pi / 2 + value * pi),
        child: Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(255, 240, 240, 240),
          ),
        ),
      ),
    );
  }
}
