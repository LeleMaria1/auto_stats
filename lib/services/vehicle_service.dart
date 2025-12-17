import 'package:hive/hive.dart';
import '../models/vehicle.dart';

class VehicleService {
  Box<Vehicle> get _vehicleBox => Hive.box<Vehicle>('vehicles');
  
  // Contador simples para IDs
  int _getNextId() {
    final box = _vehicleBox;
    if (box.isEmpty) return 1;
    final maxId = box.values.map((v) => v.id ?? 0).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  Future<int> insertVehicle(Vehicle vehicle) async {
    final box = _vehicleBox;
    if (vehicle.id == null) {
      vehicle.id = _getNextId();
    }
    await box.put(vehicle.id, vehicle);
    return vehicle.id!;
  }

  Future<List<Vehicle>> getVehicles() async {
    final box = _vehicleBox;
    return box.values.toList();
  }

  Future<int> updateVehicle(Vehicle? vehicle) async {
    if (vehicle == null || vehicle.id == null) return 0;
    await _vehicleBox.put(vehicle.id, vehicle);
    return 1;
  }

  Future<int> deleteVehicle(int? id) async {
    if (id == null) return 0;
    await _vehicleBox.delete(id);
    return 1;
  }
}