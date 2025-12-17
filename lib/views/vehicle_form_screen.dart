import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/vehicle_viewmodel.dart';
import '../models/vehicle.dart';

class VehicleFormScreen extends StatefulWidget {
  final Vehicle? vehicle;

  VehicleFormScreen({this.vehicle});

  @override
  _VehicleFormScreenState createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _plateController = TextEditingController();
  final _mileageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // SOLUÇÃO: Usar PostFrameCallback para garantir que o contexto está disponível
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadVehicleData();
    });
  }

  void _loadVehicleData() {
    // Prioridade 1: Veículo passado como argumento
    if (widget.vehicle != null) {
      _modelController.text = widget.vehicle!.model;
      _yearController.text = widget.vehicle!.year.toString();
      _plateController.text = widget.vehicle!.plate ?? '';
      _mileageController.text = widget.vehicle!.currentMileage.toStringAsFixed(0);
    } 
    // Prioridade 2: Buscar do ViewModel (para navegação via rotas nomeadas)
    else {
      final vehicleVM = context.read<VehicleViewModel>();
      final currentVehicle = vehicleVM.vehicle;
      if (currentVehicle != null && mounted) {
        _modelController.text = currentVehicle.model;
        _yearController.text = currentVehicle.year.toString();
        _plateController.text = currentVehicle.plate ?? '';
        _mileageController.text = currentVehicle.currentMileage.toStringAsFixed(0);
      }
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);

    // Determinar qual veículo estamos editando
    final existingVehicle = widget.vehicle ?? vehicleVM.vehicle;
    
    final vehicle = Vehicle(
      id: existingVehicle?.id, // Mantém o ID se estiver editando
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text),
      plate: _plateController.text.trim().isNotEmpty ? _plateController.text.trim() : null,
      currentMileage: double.parse(_mileageController.text),
      marketValue: existingVehicle?.marketValue, // Mantém o valor FIPE se existir
      lastFipeUpdate: existingVehicle?.lastFipeUpdate,
    );

    await vehicleVM.saveVehicle(vehicle);

    if (vehicleVM.errorMessage == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${vehicleVM.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Cadastrar Veículo' : 'Editar Veículo'),
        actions: [
          if (widget.vehicle != null || context.read<VehicleViewModel>().vehicle != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final confirmed = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Excluir Veículo'),
                    content: Text('Tem certeza que deseja excluir este veículo?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('Excluir', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final vehicleVM = Provider.of<VehicleViewModel>(context, listen: false);
                  await vehicleVM.deleteVehicle();
                  if (vehicleVM.errorMessage == null && mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
        ],
      ),
      body: Consumer<VehicleViewModel>(
        builder: (context, vehicleVM, child) {
          if (vehicleVM.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Modelo
                  TextFormField(
                    controller: _modelController,
                    decoration: InputDecoration(
                      labelText: 'Modelo do Veículo',
                      prefixIcon: Icon(Icons.directions_car),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o modelo';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Ano
                  TextFormField(
                    controller: _yearController,
                    decoration: InputDecoration(
                      labelText: 'Ano',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o ano';
                      }
                      final year = int.tryParse(value);
                      if (year == null || year < 1900 || year > DateTime.now().year + 1) {
                        return 'Ano inválido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Placa (opcional)
                  TextFormField(
                    controller: _plateController,
                    decoration: InputDecoration(
                      labelText: 'Placa (opcional)',
                      prefixIcon: Icon(Icons.confirmation_number),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Quilometragem
                  TextFormField(
                    controller: _mileageController,
                    decoration: InputDecoration(
                      labelText: 'Quilometragem Atual',
                      prefixIcon: Icon(Icons.speed),
                      border: OutlineInputBorder(),
                      suffixText: 'km',
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe a quilometragem';
                      }
                      final mileage = double.tryParse(value);
                      if (mileage == null || mileage < 0) {
                        return 'Quilometragem inválida';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // Botão Salvar
                  ElevatedButton(
                    onPressed: () => _saveVehicle(context),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Salvar Veículo',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  // Exibir erro se houver
                  if (vehicleVM.errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        vehicleVM.errorMessage!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}