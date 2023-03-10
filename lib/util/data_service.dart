import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:collection/collection.dart';
import 'package:path_provider/path_provider.dart';

import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../models/step.dart';

class DataService {
  static Future<List<Recipe>> generateRecipeNames(List<int> indices) async {
    try {
      var url =
          'https://us-central1-yum-recipe-3704f.cloudfunctions.net/generateRecipe';
      var responseRaw = await http
          .post(Uri.parse(url), body: {'indices': jsonEncode(indices)});
      Map response = jsonDecode(responseRaw.body);
      return List<Recipe>.from(
        List<Map<String, dynamic>>.from(response['recipes']).map(
          (e) => Recipe(
            id: e['id'],
            name: e['title'],
            image: e['image'],
            index: e['index'],
            ingredients: List<Ingredient>.from(
              List<String>.from(e['ingredients']).mapIndexed(
                (index, desc) => Ingredient(id: index, description: desc),
              ),
            ),
            steps: List<MethodStep>.from(
              List<String>.from(e['instructions']).mapIndexed(
                (index, desc) => MethodStep(id: index, description: desc),
              ),
            ),
            description: e['description'],
          ),
        ),
      );
    } catch (e) {
      print(e);
      return [];
    }
  }
}
