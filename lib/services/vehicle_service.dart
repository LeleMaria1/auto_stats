import '../models/vehicle.dart';
import '../utils/database_helper.dart';

class VehicleService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertVehicle(Vehicle vehicle) async {
    return await _dbHelper.insertVehicle(vehicle);
  }

  Future<List<Vehicle>> getVehicles() async {
    return await _dbHelper.getVehicles();
  }

  Future<Vehicle?> getVehicle(int id) async {
    return await _dbHelper.getVehicle(id);
  }

  Future<int> updateVehicle(Vehicle? vehicle) async {
    if (vehicle == null || vehicle.id == null) return 0;
    return await _dbHelper.updateVehicle(vehicle);
  }

  Future<int> deleteVehicle(int? id) async {
    if (id == null) return 0;
    return await _dbHelper.deleteVehicle(id);
  }
}