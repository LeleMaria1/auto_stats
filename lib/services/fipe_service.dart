import 'dart:convert';
import 'package:http/http.dart' as http;

class FipeService {
  
  // Método 1: BrasilAPI (mais confiável)
  Future<double?> getVehicleValueFromBrasilAPI(String model, int year) async {
    try {
      // Limpa o modelo para busca
      final searchModel = _cleanModelForSearch(model);
      
      final response = await http.get(
        Uri.parse('https://brasilapi.com.br/api/fipe/preco/v1/$searchModel'),
        headers: {'Accept': 'application/json'},
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        // Filtra pelo ano mais próximo
        final matches = data.where((item) {
          final itemYear = int.tryParse(item['anoModelo'].toString()) ?? 0;
          return itemYear == year || (year - itemYear).abs() <= 2;
        }).toList();
        
        if (matches.isNotEmpty) {
          final match = matches.first;
          final valueStr = match['valor'].toString();
          final cleanValue = valueStr
              .replaceAll('R\$', '')
              .replaceAll('.', '')
              .replaceAll(',', '.')
              .trim();
          
          return double.tryParse(cleanValue);
        }
      }
      return null;
    } catch (e) {
      print('BrasilAPI error: $e');
      return null;
    }
  }
  
  // Método 2: Cálculo simulado (fallback)
  Future<double> getVehicleValue(String brand, String model, int year) async {
    await Future.delayed(Duration(seconds: 2)); // Simula delay da API
    
    // Tabela de valores base por marca
    final Map<String, double> baseValues = {
      'fiat': 28000.0,
      'volkswagen': 42000.0,
      'ford': 38000.0,
      'chevrolet': 40000.0,
      'toyota': 55000.0,
      'honda': 52000.0,
      'hyundai': 35000.0,
      'renault': 32000.0,
      'jeep': 65000.0,
      'nissan': 45000.0,
    };
    
    // Encontra valor base
    double baseValue = 30000.0;
    final brandLower = brand.toLowerCase();
    
    for (var key in baseValues.keys) {
      if (brandLower.contains(key)) {
        baseValue = baseValues[key]!;
        break;
      }
    }
    
    // Ajustes por modelo específico
    final modelLower = model.toLowerCase();
    if (modelLower.contains('uno') || modelLower.contains('mobi')) baseValue *= 0.9;
    if (modelLower.contains('gol') || modelLower.contains('palio')) baseValue *= 0.95;
    if (modelLower.contains('corolla') || modelLower.contains('civic')) baseValue *= 1.2;
    if (modelLower.contains('hilux') || modelLower.contains('ranger')) baseValue *= 1.5;
    
    // Desvalorização por ano (7% ao ano)
    final currentYear = DateTime.now().year;
    final yearsOld = currentYear - year;
    final depreciation = yearsOld * 0.07;
    final finalValue = baseValue * (1 - depreciation).clamp(0.2, 1.0);
    
    return finalValue.roundToDouble();
  }
  
  // Limpa o modelo para busca na API
  String _cleanModelForSearch(String model) {
    // Remove espaços extras e caracteres especiais
    return model
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');
  }
}