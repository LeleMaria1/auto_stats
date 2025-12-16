import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehicleViewModel with ChangeNotifier {
  Vehicle? _vehicle;
  bool _isLoading = false;

  Vehicle? get vehicle => _vehicle;
  bool get isLoading => _isLoading;
  double? get marketValue => _vehicle?.marketValue;

  void setVehicle(Vehicle v) {
    _vehicle = v;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Simulação de API FIPE (vamos integrar depois)
  Future<void> fetchFipeValue() async {
    if (_vehicle == null) return;

    setLoading(true);
    await Future.delayed(Duration(seconds: 2)); // Simula delay
    _vehicle!.marketValue = 45000.0; // Valor fixo para teste
    _vehicle!.lastFipeUpdate = DateTime.now();
    setLoading(false);
    notifyListeners();
  }
}