import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../services/fipe_service.dart';

class VehicleViewModel with ChangeNotifier {
  Vehicle? _vehicle;
  bool _isLoading = false;
  bool _isFetchingFipe = false;
  String? _errorMessage;

  Vehicle? get vehicle => _vehicle;
  bool get isLoading => _isLoading;
  bool get isFetchingFipe => _isFetchingFipe;
  String? get errorMessage => _errorMessage;
  double? get marketValue => _vehicle?.marketValue;

  final VehicleService _vehicleService = VehicleService();
  final FipeService _fipeService = FipeService();

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

    _isFetchingFipe = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Tenta usar a BrasilAPI primeiro
      double? fipeValue = await _fipeService.getVehicleValueFromBrasilAPI(
        _vehicle!.model,
        _vehicle!.year,
      );

      // Se falhar, usa o método simulado
      if (fipeValue == null) {
        fipeValue = await _fipeService.getVehicleValue(
          _extractBrandFromModel(_vehicle!.model),
          _vehicle!.model,
          _vehicle!.year,
        );
      }

      if (fipeValue != null && fipeValue > 0) {
        _vehicle!.marketValue = fipeValue;
        _vehicle!.lastFipeUpdate = DateTime.now();
        await _vehicleService.updateVehicle(_vehicle);
        
        print('✅ Valor FIPE atualizado: R\$ $fipeValue');
      } else {
        _errorMessage = 'Não foi possível obter o valor FIPE para este veículo';
      }
    } catch (e) {
      _errorMessage = 'Erro na consulta FIPE: ${e.toString()}';
      print('❌ Erro FIPE: $e');
      
      // Fallback: valor simulado em caso de erro
      try {
        final simulatedValue = await _fipeService.getVehicleValue(
          _extractBrandFromModel(_vehicle!.model),
          _vehicle!.model,
          _vehicle!.year,
        );
        
        if (simulatedValue != null) {
          _vehicle!.marketValue = simulatedValue;
          _vehicle!.lastFipeUpdate = DateTime.now();
          await _vehicleService.updateVehicle(_vehicle);
          _errorMessage = 'Valor estimado (API indisponível)';
        }
      } catch (e2) {
        _errorMessage = 'Serviço FIPE indisponível no momento';
      }
    } finally {
      _isFetchingFipe = false;
      notifyListeners();
    }
  }

  String _extractBrandFromModel(String model) {
    // Extrai a marca do modelo (ex: "Fiat Uno" -> "Fiat")
    final commonBrands = [
      'Fiat', 'Volkswagen', 'Ford', 'Chevrolet', 'Toyota', 
      'Honda', 'Hyundai', 'Renault', 'Jeep', 'Nissan'
    ];
    
    for (var brand in commonBrands) {
      if (model.toLowerCase().contains(brand.toLowerCase())) {
        return brand;
      }
    }
    
    // Retorna primeira palavra como fallback
    return model.split(' ').first;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Método para teste rápido (opcional)
  Future<void> testFipeWithMockData() async {
    if (_vehicle == null) {
      // Cria veículo de teste
      final testVehicle = Vehicle(
        model: 'Fiat Uno',
        year: 2020,
        currentMileage: 45000,
      );
      await saveVehicle(testVehicle);
    }
    
    await fetchFipeValue();
  }
}