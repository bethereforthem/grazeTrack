class FeedModel {
  final String id;
  final String animalCategory;
  final String userId;
  final String type;
  final double quantity;
  final String unit;
  final double cost;
  final String notes;
  final String date;

  const FeedModel({
    required this.id,
    required this.animalCategory,
    required this.userId,
    required this.type,
    required this.quantity,
    this.unit = 'kg',
    required this.cost,
    this.notes = '',
    required this.date,
  });

  factory FeedModel.fromJson(Map<String, dynamic> json) => FeedModel(
        id: json['id'] ?? '',
        animalCategory: json['animalCategory'] ?? json['animalId'] ?? '',
        userId: json['userId'] ?? '',
        type: json['type'] ?? '',
        quantity: (json['quantity'] ?? 0).toDouble(),
        unit: json['unit'] ?? 'kg',
        cost: (json['cost'] ?? 0).toDouble(),
        notes: json['notes'] ?? '',
        date: json['date'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'animalCategory': animalCategory,
        'type': type,
        'quantity': quantity,
        'unit': unit,
        'cost': cost,
        'notes': notes,
        'date': date,
      };
}
