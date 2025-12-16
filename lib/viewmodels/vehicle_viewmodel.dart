import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';

class VehicleViewModel with ChangeNotifier {
  Vehicle? _vehicle;
  bool _isLoading = false;
  String? _errorMessage;

  Vehicle? get vehicle => _vehicle;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double? get marketValue => _vehicle?.marketValue;

  final VehicleService _vehicleService = VehicleService();

  VehicleViewModel() {
    _loadVehicle();
  }

  Future<void> _loadVehicle() async {
    setLoading(true);
    try {
      final vehicles = await _vehicleService.getVehicles();
      if (vehicles.isNotEmpty) {
        _vehicle = vehicles.first;
      }
    } catch (e) {
      _errorMessage = 'Erro ao carregar veículo: $e';
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> saveVehicle(Vehicle vehicle) async {
    setLoading(true);
    try {
      if (vehicle.id == null) {
        final id = await _vehicleService.insertVehicle(vehicle);
        vehicle.id = id;
      } else {
        await _vehicleService.updateVehicle(vehicle);
      }
      _vehicle = vehicle;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao salvar veículo: $e';
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> deleteVehicle() async {
    if (_vehicle == null || _vehicle!.id == null) return;

    setLoading(true);
    try {
      await _vehicleService.deleteVehicle(_vehicle!.id!);
      _vehicle = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao excluir veículo: $e';
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> fetchFipeValue() async {
    if (_vehicle == null) return;

    setLoading(true);
    try {
      // TODO: Integrar com API FIPE real
      await Future.delayed(Duration(seconds: 2)); // Simulação
      _vehicle!.marketValue = 45000.0;
      _vehicle!.lastFipeUpdate = DateTime.now();
      await _vehicleService.updateVehicle(_vehicle!);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao buscar valor FIPE: $e';
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}