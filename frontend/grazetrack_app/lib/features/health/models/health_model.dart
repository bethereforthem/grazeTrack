class HealthModel {
  final String id;
  final String animalId;
  final String userId;
  final String type;
  final String vaccination;
  final String status;
  final String description;
  final String medicine;
  final double cost;
  final String vet;
  final String nextCheckupDate;
  final String date;
  final String animalType; // e.g. Cow, Goat — used for category filtering

  const HealthModel({
    required this.id,
    required this.animalId,
    required this.userId,
    required this.type,
    this.vaccination = '',
    required this.status,
    this.description = '',
    this.medicine = '',
    this.cost = 0,
    this.vet = '',
    this.nextCheckupDate = '',
    required this.date,
    this.animalType = '',
  });

  factory HealthModel.fromJson(Map<String, dynamic> json) => HealthModel(
        id: json['id'] ?? '',
        animalId: json['animalId'] ?? '',
        userId: json['userId'] ?? '',
        type: json['type'] ?? '',
        vaccination: json['vaccination'] ?? '',
        status: json['status'] ?? 'healthy',
        description: json['description'] ?? '',
        medicine: json['medicine'] ?? '',
        cost: (json['cost'] ?? 0).toDouble(),
        vet: json['vet'] ?? '',
        nextCheckupDate: json['nextCheckupDate'] ?? '',
        date: json['date'] ?? '',
        animalType: json['animalType'] ?? '',
      );
}
