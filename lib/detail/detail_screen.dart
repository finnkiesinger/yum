import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yum/detail/ingredients_widget.dart';
import 'package:yum/detail/instructions_widget.dart';
import 'package:yum/util/tap_scale.dart';

import '../constants.dart';
import '../models/recipe.dart';

class DetailScreen extends StatefulWidget {
  final Recipe recipe;

  const DetailScreen(this.recipe, {Key? key}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  var _offset = 0.0;

  double _calculateImageOffset() {
    if (_offset > 0) {
      return max(MediaQuery.of(context).size.height * 2 / 3 - _offset * 0.15,
          MediaQuery.of(context).size.width);
    } else {
      return MediaQuery.of(context).size.height * 2 / 3 - _offset;
    }
  }

  var _tab = 0;

  _switchTab(int i) {
    return () {
      _animationController.fling();
      _open = true;
      setState(() {
        _tab = i;
      });
    };
  }

  var _open = false;
  var _ignore = false;

  _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      if (_ignore) {
        return;
      }
      _offset -= details.delta.dy;
      _offset = _offset.clamp(0, MediaQuery.of(context).size.height * 2 / 3);
      _animationController.value =
          _offset / (MediaQuery.of(context).size.height * 2 / 3);
      if (!_open && _animationController.value > 0.5) {
        _ignore = true;
        _animationController.fling();
        _open = true;
        HapticFeedback.selectionClick();
        return;
      }
      if (_open && _animationController.value < 0.5) {
        _animationController.fling(velocity: -1);
        _open = false;
        _ignore = true;
        HapticFeedback.selectionClick();
        return;
      }
    });
  }

  _onDragEnd(DragEndDetails details) {
    setState(() {
      if (details.velocity.pixelsPerSecond.dy < -500) {
        _animationController.fling(velocity: 1);
        if (!_ignore && !_open) {
          HapticFeedback.selectionClick();
        }
        _open = true;
      } else if (details.velocity.pixelsPerSecond.dy > 500) {
        _animationController.fling(velocity: -1);
        if (!_ignore && _open) {
          HapticFeedback.selectionClick();
        }
        _open = false;
      } else if (_animationController.value > 0.5) {
        _animationController.fling(velocity: 1);
        _open = true;
      } else {
        _animationController.fling(velocity: -1);
      }
      _ignore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            _offset = _animationController.value *
                (MediaQuery.of(context).size.height * 2 / 3);
            return Stack(
              children: [
                Positioned(
                  top: min(0, -_offset * 0.3),
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: _calculateImageOffset(),
                    child: CachedNetworkImage(
                      imageUrl: widget.recipe.image,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: orange,
                        ),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: TapScale(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 3,
                              sigmaY: 3,
                            ),
                            child: Container(
                              height: 48,
                              width: 48,
                              decoration: const BoxDecoration(
                                color: Colors.white70,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.black,
                                size: 42,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: (MediaQuery.of(context).size.height * 2 / 3 - 50) *
                      (1 - _animation.value),
                  height: MediaQuery.of(context).size.height,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onVerticalDragUpdate: _onDragUpdate,
                    onVerticalDragEnd: _onDragEnd,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: (MediaQuery.of(context).viewPadding.top) *
                                  _animation.value),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  height: 6,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 24 * _animation.value,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0).copyWith(
                              right: 48,
                              top: 0,
                            ),
                            child: AutoSizeText(
                              widget.recipe.name.replaceAll('"', ''),
                              maxFontSize: 28,
                              maxLines: 2,
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 28,
                                height: 1.2,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              widget.recipe.description,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18.0,
                              horizontal: 12.0,
                            ).copyWith(top: 32),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 245, 245, 245),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  RecipeTabItem(
                                    active: _tab == 0,
                                    onSelect: _switchTab(0),
                                    title: 'Ingredients',
                                  ),
                                  RecipeTabItem(
                                    active: _tab == 1,
                                    onSelect: _switchTab(1),
                                    title: 'Instructions',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: _tab == 0
                                  ? IngredientsWidget(
                                      open: _open,
                                      ingredients: widget.recipe.ingredients
                                          .map((e) => e.description)
                                          .toList(),
                                    )
                                  : InstructionsWidget(
                                      open: _open,
                                      instructions: widget.recipe.steps
                                          .map((e) => e.description)
                                          .toList(),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  left: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.6),
                          ],
                          stops: [
                            0,
                            0.3,
                            1,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class RecipeTabItem extends StatelessWidget {
  final String title;
  final bool active;
  final Function() onSelect;

  const RecipeTabItem({
    required this.title,
    required this.active,
    required this.onSelect,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: TapScale(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelect();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active ? orange : const Color.fromARGB(255, 245, 245, 245),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: active ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
