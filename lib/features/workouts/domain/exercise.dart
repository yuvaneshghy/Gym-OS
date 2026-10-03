class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    this.description,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      bodyPart: json['body_part'] as String,
      description: json['description'] as String?,
    );
  }

  final String id;
  final String name;
  final String bodyPart;
  final String? description;

  Map<String, dynamic> toJson() => {
        'name': name,
        'body_part': bodyPart,
        if (description != null) 'description': description,
      };
}
