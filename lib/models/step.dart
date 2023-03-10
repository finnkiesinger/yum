class MethodStep {
  final int id;
  String description;

  MethodStep({
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

  factory MethodStep.fromJson(Map<String, dynamic> json) {
    return MethodStep(
      id: json['id'],
      description: json['description'],
    );
  }
}
