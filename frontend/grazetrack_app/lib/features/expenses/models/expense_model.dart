class ExpenseModel {
  final String id;
  final String userId;
  final String type;
  final String description;
  final double amount;
  final String animalId;
  final String date;

  const ExpenseModel({
    required this.id,
    required this.userId,
    required this.type,
    this.description = '',
    required this.amount,
    this.animalId = '',
    required this.date,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
        id: json['id'] ?? '',
        userId: json['userId'] ?? '',
        type: json['type'] ?? '',
        description: json['description'] ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        animalId: json['animalId'] ?? '',
        date: json['date'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'description': description,
        'amount': amount,
        'animalId': animalId,
        'date': date,
      };
}
