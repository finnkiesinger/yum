import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yum/constants.dart';
import 'package:yum/detail/detail_screen.dart';
import 'package:yum/home/dot_layer.dart';
import 'package:yum/home/hint.dart';
import 'package:yum/home/idea_widget.dart';
import 'package:yum/home/recipe_list_screen.dart';
import 'package:yum/models/dot_data.dart';
import 'package:yum/models/recipe.dart';
import 'package:yum/util/data_service.dart';
import 'package:yum/util/recipe_store.dart';
import 'package:yum/util/tap_scale.dart';

import 'generate_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _dotController = DotController();
  Timer? _pulseTimer;

  var _isInitial = true;
  var _isIdeas = false;
  var _isLoadingTitles = false;
  var _isGenerating = false;
  var _pulse = false;
  Future? _delayFuture;

  var _recipeIdeas = <Recipe>[];

  loadRecipeTitles() async {
    if (context.read<RecipeStore>().credits <= 0) {
      // TODO: open credits screen
      return;
    }
    _isInitial = false;
    _isIdeas = false;
    _isLoadingTitles = true;
    setState(() {});

    var size = MediaQuery.of(context).size;
    _dotController.addWave(Offset(size.width / 2, size.height / 2));
    _pulseTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _dotController.addWave(Offset(size.width / 2, size.height / 2));
      _pulse = !_pulse;
      setState(() {});
      Future.delayed(const Duration(milliseconds: 150), () {
        _pulse = !_pulse;
        setState(() {});
      });
    });

    _delayFuture = Future.delayed(const Duration(seconds: 2));
    _recipeIdeas = await DataService.generateRecipeNames(
        context.read<RecipeStore>().recipes.map((e) => e.index).toList());
    if (!mounted) return;
    await _delayFuture;
    _delayFuture = null;

    _pulseTimer?.cancel();
    if (!mounted) return;
    _isLoadingTitles = false;
    _isIdeas = true;
    setState(() {});
  }

  generateRecipe(Recipe recipe) async {
    _isIdeas = false;
    _isGenerating = true;
    setState(() {});
    var size = MediaQuery.of(context).size;
    _dotController.addWave(Offset(size.width / 2, size.height / 2));
    _pulseTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _dotController.addWave(Offset(size.width / 2, size.height / 2));
    });

    await Future.delayed(const Duration(seconds: 3));

    _pulseTimer?.cancel();
    if (!mounted) return;
    _isGenerating = false;
    var localStorage = await SharedPreferences.getInstance();
    if (!mounted) return;

    localStorage.setStringList('recipes', [
      ...?localStorage.getStringList('recipes'),
      jsonEncode(recipe.toJson()),
    ]);
    context.read<RecipeStore>().addRecipe(recipe);
    setState(() {});

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetailScreen(recipe),
      ),
    );
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _dotController.clear();
      for (var i = 0; i < 5; i++) {
        _dotController.addGravity(size);
      }
    });
    _isInitial = true;
    setState(() {});
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    super.dispose();
  }

  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      for (int i = 0; i < 5; i++) {
        _dotController.addGravity(MediaQuery.of(context).size);
      }
    });
  }

  var _dragOffset = 0.0;
  var _open = false;

  _onDragUpdate(DragUpdateDetails details) {
    _dragOffset -= details.delta.dx;
    _dragOffset = _dragOffset.clamp(0, MediaQuery.of(context).size.width);
    _animationController.value =
        (_dragOffset / MediaQuery.of(context).size.width).clamp(0, 1);
  }

  var _animate = true;
  var _drag = false;

  _onDragEnd(DragEndDetails? details) {
    if (details != null) {
      if (details.velocity.pixelsPerSecond.dx < -500) {
        _animationController
            .fling(velocity: 1)
            .then((value) => setState(() {}));
        _dragOffset = MediaQuery.of(context).size.width;
        _open = true;
      } else if (details.velocity.pixelsPerSecond.dx > 500) {
        _animationController
            .fling(velocity: -1)
            .then((value) => setState(() {}));
        _dragOffset = 0;
        _open = false;
      } else if (_dragOffset > MediaQuery.of(context).size.width / 2) {
        _animationController.fling();
        _dragOffset = MediaQuery.of(context).size.width;
        _open = true;
      } else {
        _animationController
            .fling(velocity: -1)
            .then((value) => setState(() {}));
        _dragOffset = 0;
        _open = false;
      }
      _changeAnimation();
      return;
    }
    if (_dragOffset > MediaQuery.of(context).size.width / 2) {
      _animationController.fling();
      _dragOffset = MediaQuery.of(context).size.width;
      _open = true;
    } else {
      _animationController.fling(velocity: -1).then((value) => setState(() {}));
      _dragOffset = 0;
      _open = false;
    }
    _changeAnimation();
  }

  _changeAnimation() {
    if (!_open && _drag) {
      _drag = false;
      _animate = true;
      for (int i = 0; i < 4; i++) {
        _dotController.addGravity(MediaQuery.of(context).size);
      }
    }
  }

  _onDragStart(DragStartDetails details) {
    _drag = true;
    _animate = false;
    setState(() {});
    _dotController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _animate
                ? DotLayer(
                    horizontal: 22,
                    vertical: 44,
                    controller: _dotController,
                    animate: _animate,
                  )
                : Container(),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragCancel: () {
              _onDragEnd(null);
            },
            child: IgnorePointer(
              child: Container(color: Colors.transparent),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height / 2 -
                        80 -
                        MediaQuery.of(context).viewPadding.top,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: _isInitial ? 1 : 0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: GenerateButton(
                            onTapDown: () {
                              _dotController.gravitateToCenter(
                                  MediaQuery.of(context).size);
                            },
                            onTapEnd: () {
                              _dotController.removeCenterGravity();
                            },
                            onTap: () {
                              loadRecipeTitles();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedPositioned(
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 500),
                    top: _isInitial
                        ? MediaQuery.of(context).size.height / 2 - 200
                        : MediaQuery.of(context).size.height / 2 -
                            10 -
                            MediaQuery.of(context).viewPadding.vertical,
                    right: 0,
                    left: 0,
                    child: AnimatedScale(
                      curve: Curves.easeInOutCubic,
                      duration: const Duration(milliseconds: 150),
                      scale: !_isInitial && !_isLoadingTitles
                          ? 0
                          : _pulse
                              ? 0.95
                              : 1,
                      child: Hint(
                        state: _isInitial ? HintState.initial : HintState.ideas,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedScale(
                        curve: Curves.easeInOut,
                        duration: const Duration(milliseconds: 500),
                        scale: _isIdeas ? 1 : 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child:
                                      Image.asset('assets/images/sparkle.png'),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Ideas',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child:
                                      Image.asset('assets/images/sparkle.png'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ..._recipeIdeas.map(
                              (e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: IdeaWidget(
                                  idea: e.name,
                                  onSelect: () {
                                    generateRecipe(e);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TapScale(
                              onTap: () {
                                loadRecipeTitles();
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: orange,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: orange.withOpacity(0.5),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedScale(
                      curve: Curves.easeInOut,
                      duration: const Duration(milliseconds: 150),
                      scale: _isGenerating ? 1 : 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: Image.asset('assets/images/sparkle.png'),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Generating...',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF646464),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  /*TapScale(
                    onTap: () {},
                    child: const CreditsCounter(),
                  ),
                   */
                ],
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !_open,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return GestureDetector(
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _animation.value * 10,
                      sigmaY: _animation.value * 10,
                    ),
                    child: Container(
                      color: Colors.black.withOpacity(
                        _animation.value * 0.1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          AnimatedOpacity(
            opacity: _isInitial && !_open ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TapScale(
                    onTap: () {
                      _open = true;
                      setState(() {});
                      _animationController
                          .fling(velocity: 1)
                          .then((value) => setState(() {}));
                      _dragOffset = MediaQuery.of(context).size.width;
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 2,
                          sigmaY: 2,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Show History',
                            style: TextStyle(
                              color: Color(0xFF646464),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: 0,
                bottom: 0,
                width: MediaQuery.of(context).size.width,
                left:
                    (1 - _animation.value) * MediaQuery.of(context).size.width,
                child: GestureDetector(
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                  child: const RecipeListScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
