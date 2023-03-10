import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants.dart';

class CreditsCounter extends StatelessWidget {
  static _formatCredits(int credits) {
    final formatter = NumberFormat('#,###');
    return formatter.format(credits);
  }

  const CreditsCounter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 3),
            Container(
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                color: orange,
                boxShadow: [
                  BoxShadow(
                    color: orange.withOpacity(0.25),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 30,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    constraints: BoxConstraints(
                      minWidth: 30,
                    ),
                    child: Center(
                      child: Text(
                        _formatCredits(5),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 34,
                    width: 34,
                    padding: const EdgeInsets.all(5),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white24,
                      ),
                      child: const Icon(
                        CupertinoIcons.plus,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Color.alphaBlend(orange.withOpacity(0.3), Colors.white),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.flame_fill,
            color: orange,
            size: 20,
          ),
        ),
      ],
    );
  }
}
