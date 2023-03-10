import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../util/tap_scale.dart';

class InstructionsWidget extends StatelessWidget {
  final List<String> instructions;
  final bool open;

  final PageController _pageController = PageController();

  InstructionsWidget({
    required this.instructions,
    required this.open,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: PageView(
        controller: _pageController,
        children: instructions.mapIndexed(
          (index, instruction) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step ${index + 1}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              instruction,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 56),
                          ],
                        ),
                      ),
                      if (index > 0)
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: TapScale(
                            onTap: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                              HapticFeedback.selectionClick();
                            },
                            child: Container(
                              color: Colors.transparent,
                              height: 44,
                              width: 44,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (index < instructions.length - 1)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TapScale(
                            onTap: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                              HapticFeedback.selectionClick();
                            },
                            child: Container(
                              color: Colors.transparent,
                              height: 44,
                              width: 44,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
