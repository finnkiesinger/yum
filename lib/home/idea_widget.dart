import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:yum/util/tap_scale.dart';

class IdeaWidget extends StatelessWidget {
  final String idea;
  final Function() onSelect;

  const IdeaWidget({
    required this.idea,
    required this.onSelect,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 2,
          sigmaY: 2,
        ),
        child: TapScale(
          onTap: onSelect,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 24,
            ),
            decoration: BoxDecoration(
              color: Colors.black12.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              idea.replaceAll('"', ''),
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
