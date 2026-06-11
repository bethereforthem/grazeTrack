// Animal data model — mirrors the Firestore animal document structure
class AnimalModel {
  final String id;
  final String userId;
  final String name;
  final String type;
  final String breed;
  final int age; // age in months at time of registration
  final String gender;
  final double weight;
  final double purchaseCost;
  final String status; // active | sold | deceased
  final String photoUrl;
  final String notes;
  final String createdAt;
  final String? parentId;   // Item 9: link born animals to parent
  final double? soldPrice;  // price animal was sold for
  final String? soldAt;     // when it was sold/died

  const AnimalModel({
    required this.id,
    required this.userId,
    this.name = '',
    required this.type,
    this.breed = '',
    this.age = 0,
    this.gender = '',
    this.weight = 0,
    required this.purchaseCost,
    this.status = 'active',
    this.photoUrl = '',
    this.notes = '',
    this.createdAt = '',
    this.parentId,
    this.soldPrice,
    this.soldAt,
  });

  // Item 2: Compute current age by adding elapsed months since registration.
  // Stops incrementing once the animal is sold or deceased.
  int get currentAge {
    if (createdAt.isEmpty) return age;
    try {
      final registered = DateTime.parse(createdAt);
      final reference = (status == 'active')
          ? DateTime.now()
          : (soldAt != null && soldAt!.isNotEmpty
              ? DateTime.parse(soldAt!)
              : DateTime.now());
      final elapsed = reference.difference(registered);
      final monthsElapsed = (elapsed.inDays / 30).floor();
      return age + (monthsElapsed > 0 ? monthsElapsed : 0);
    } catch (_) {
      return age;
    }
  }

  // Convert JSON from API response into an AnimalModel object
  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      breed: json['breed'] ?? '',
      age: (json['age'] ?? 0).toInt(),
      gender: json['gender'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      purchaseCost: (json['purchaseCost'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
      photoUrl: json['photoUrl'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: json['createdAt'] ?? '',
      parentId: json['parentId'],
      soldPrice: json['soldPrice'] != null
          ? (json['soldPrice'] as num).toDouble()
          : null,
      soldAt: json['soldAt'],
    );
  }

  // Convert to a Map for sending to the API
  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'breed': breed,
        'age': age,
        'gender': gender,
        'weight': weight,
        'purchaseCost': purchaseCost,
        'notes': notes,
        if (parentId != null) 'parentId': parentId,
      };
}
