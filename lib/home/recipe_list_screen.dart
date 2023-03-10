import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yum/detail/detail_screen.dart';
import 'package:yum/util/recipe_store.dart';
import 'package:yum/util/tap_scale.dart';

import '../models/recipe.dart';

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({Key? key}) : super(key: key);

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  var _query = '';

  bool _filter(Recipe recipe) {
    if (recipe.name.toLowerCase().contains(_query.toLowerCase())) {
      return true;
    }
    for (var ingredient in recipe.ingredients) {
      if (ingredient.description.toLowerCase().contains(_query.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0).copyWith(
              bottom: 8.0,
              top: 16.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0).copyWith(left: 12),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Colors.black54,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      cursorColor: Colors.black,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 1.3,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: const TextStyle(
                          color: Colors.black54,
                          fontSize: 20,
                          height: 1.3,
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.all(16).copyWith(
                          left: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero.copyWith(
              top: 8.0,
              bottom: MediaQuery.of(context).viewPadding.bottom,
            ),
            children: [
              ...context
                  .watch<RecipeStore>()
                  .recipes
                  .where(_filter)
                  .map(
                    (recipe) {
                      return Padding(
                        key: ValueKey(recipe.id),
                        padding: const EdgeInsets.all(8.0),
                        child: TapScale(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(recipe),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: CachedNetworkImage(
                                    imageUrl: recipe.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    recipe.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                  .toList()
                  .reversed,
            ],
          ),
        ),
      ],
    );
  }
}
