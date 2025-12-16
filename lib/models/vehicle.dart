class Vehicle {
  int? id;
  String model;
  int year;
  String? plate;
  double currentMileage;
  double? marketValue;
  DateTime? lastFipeUpdate;

  Vehicle({
    this.id,
    required this.model,
    required this.year,
    this.plate,
    required this.currentMileage,
    this.marketValue,
    this.lastFipeUpdate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'model': model,
      'year': year,
      'plate': plate,
      'currentMileage': currentMileage,
      'marketValue': marketValue,
      'lastFipeUpdate': lastFipeUpdate?.toIso8601String(),
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      model: map['model'],
      year: map['year'],
      plate: map['plate'],
      currentMileage: map['currentMileage'],
      marketValue: map['marketValue'],
      lastFipeUpdate: map['lastFipeUpdate'] != null
          ? DateTime.parse(map['lastFipeUpdate'])
          : null,
    );
  }
}