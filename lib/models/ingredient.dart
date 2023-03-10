class Ingredient {
  int id;
  String description;

  Ingredient({
    required this.id,
    required this.description,
  });

  bool get isValid => description.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
    };
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['id'],
      description: json['description'],
    );
  }
}
