import 'package:hive/hive.dart';

part 'vehicle.g.dart';

@HiveType(typeId: 0)
class Vehicle {
  @HiveField(0)
  int? id;
  
  @HiveField(1)
  String model;
  
  @HiveField(2)
  int year;
  
  @HiveField(3)
  String? plate;
  
  @HiveField(4)
  double currentMileage;
  
  @HiveField(5)
  double? marketValue;
  
  @HiveField(6)
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
}