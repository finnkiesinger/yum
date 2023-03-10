import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/recipe.dart';

class RecipeStore extends ChangeNotifier {
  final List<Recipe> _recipes = [];

  late int _credits;

  List<Recipe> get recipes => _recipes;

  int get credits => _credits;

  void addRecipe(Recipe recipe) {
    _recipes.add(recipe);
    notifyListeners();
  }

  void removeCredit() {
    assert(_credits > 0, 'No credits left');
    _credits--;
    notifyListeners();
  }

  void addCredits(int amount) {
    assert(amount > 0, 'Amount must be greater than 0');
    _credits += amount;
    notifyListeners();
  }

  RecipeStore() {
    var localStorage = SharedPreferences.getInstance();
    localStorage.then(
      (value) {
        if (value.getStringList('recipes') != null) {
          for (var recipe in value.getStringList('recipes')!) {
            addRecipe(Recipe.fromJson(jsonDecode(recipe)));
          }
        }
        if (value.getInt('credits') != null) {
          _credits = value.getInt('credits')!;
        } else {
          _credits = 5;
        }
      },
    );
  }
}
