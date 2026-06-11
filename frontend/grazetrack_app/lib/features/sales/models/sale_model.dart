class SaleModel {
  final String id;
  final String animalId;
  final String userId;
  final String animalType;
  final String animalBreed;
  final double sellingPrice;
  final double totalCost;
  final double profit;
  final double roi;
  final bool isProfit;
  final String buyerName;
  final String notes;
  final String date;

  const SaleModel({
    required this.id,
    required this.animalId,
    required this.userId,
    this.animalType = '',
    this.animalBreed = '',
    required this.sellingPrice,
    required this.totalCost,
    required this.profit,
    this.roi = 0,
    this.isProfit = true,
    this.buyerName = '',
    this.notes = '',
    required this.date,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) => SaleModel(
        id: json['id'] ?? '',
        animalId: json['animalId'] ?? '',
        userId: json['userId'] ?? '',
        animalType: json['animalType'] ?? '',
        animalBreed: json['animalBreed'] ?? '',
        sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
        totalCost: (json['totalCost'] ?? 0).toDouble(),
        profit: (json['profit'] ?? 0).toDouble(),
        roi: (json['roi'] ?? 0).toDouble(),
        isProfit: json['isProfit'] ?? true,
        buyerName: json['buyerName'] ?? '',
        notes: json['notes'] ?? '',
        date: json['date'] ?? '',
      );
}
