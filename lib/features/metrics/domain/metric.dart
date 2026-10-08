class Metric {
  const Metric({
    required this.id,
    required this.memberId,
    required this.date,
    this.weightKg,
    this.bodyFatPercent,
    this.notes,
  });

  factory Metric.fromJson(Map<String, dynamic> json) {
    return Metric(
      id: json['id'] as String,
      memberId: json['member'] as String,
      date: DateTime.parse(json['date'] as String),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      bodyFatPercent: (json['body_fat_percent'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  final String id;
  final String memberId;
  final DateTime date;
  final double? weightKg;
  final double? bodyFatPercent;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'member': memberId,
        'date': date.toIso8601String(),
        if (weightKg != null) 'weight_kg': weightKg,
        if (bodyFatPercent != null) 'body_fat_percent': bodyFatPercent,
        if (notes != null) 'notes': notes,
      };
}
