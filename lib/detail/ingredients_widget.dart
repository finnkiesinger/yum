import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class IngredientsWidget extends StatelessWidget {
  final List<String> ingredients;
  final bool open;

  const IngredientsWidget({
    required this.ingredients,
    required this.open,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...ingredients.mapIndexed(
                      (index, ingredient) => Column(
                        children: [
                          if (index == 0) const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.all(16.0)
                                .copyWith(top: 8, bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ingredient,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (index < ingredients.length - 1)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Divider(
                                height: 16,
                                thickness: 1,
                                color: Colors.black.withOpacity(0.05),
                              ),
                            ),
                          if (index == ingredients.length - 1)
                            const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
