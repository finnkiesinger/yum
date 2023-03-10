import 'ingredient.dart';
import 'step.dart';

class Recipe {
  final String id;
  final String name;
  final int index;
  final List<Ingredient> ingredients;
  final List<MethodStep> steps;
  String image;
  final String description;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.index,
    required this.steps,
    required this.image,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'ingredients': ingredients.map((e) => e.toJson()).toList(),
        'steps': steps.map((e) => e.toJson()).toList(),
        'image': image,
        'index': index,
        'description': description,
      };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'],
        name: json['name'],
        index: json['index'],
        ingredients: List<Ingredient>.from(
            json['ingredients'].map((x) => Ingredient.fromJson(x))),
        steps: List<MethodStep>.from(
            json['steps'].map((x) => MethodStep.fromJson(x))),
        image: json['image'],
        description: json['description'],
      );
}
