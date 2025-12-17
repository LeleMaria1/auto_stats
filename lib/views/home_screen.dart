import 'package:auto_stats/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/vehicle_viewmodel.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../widgets/dashboard_card.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AutoStats'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
        ],
      ),
      body: Consumer2<VehicleViewModel, ExpenseViewModel>(
        builder: (context, vehicleVM, expenseVM, child) {
          if (vehicleVM.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final totalSpent = expenseVM.totalExpenses;
          final marketValue = vehicleVM.marketValue ?? 0.0;
          final tcoComparison = marketValue > 0 ? totalSpent - marketValue : null;

          // USANDO LISTVIEW EM VEZ DE COLUMN COM SCROLLVIEW
          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              // Veículo atual
              if (vehicleVM.vehicle != null)
                Card(
                  child: ListTile(
                    leading: Icon(Icons.directions_car),
                    title: Text(vehicleVM.vehicle!.model),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${vehicleVM.vehicle!.year} • ${vehicleVM.vehicle!.currentMileage.toStringAsFixed(0)} km'),
                        if (vehicleVM.vehicle!.lastFipeUpdate != null)
                          Text(
                            'FIPE: ${vehicleVM.vehicle!.lastFipeUpdate!.day}/${vehicleVM.vehicle!.lastFipeUpdate!.month}/${vehicleVM.vehicle!.lastFipeUpdate!.year}',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/vehicle-form',
                              arguments: vehicleVM.vehicle,
                            );
                          },
                        ),
                        vehicleVM.isFetchingFipe
                            ? Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                                icon: Icon(Icons.update),
                                onPressed: () async {
                                  if (vehicleVM.vehicle != null) {
                                    await vehicleVM.fetchFipeValue();
                                    
                                    if (vehicleVM.errorMessage == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('✅ Valor FIPE atualizado!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else if (vehicleVM.errorMessage!.contains('estimado')) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('⚠️ ${vehicleVM.errorMessage}'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Cadastre um veículo primeiro'),
                                      ),
                                    );
                                  }
                                },
                              ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  child: ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Nenhum veículo cadastrado'),
                    subtitle: Text('Toque para cadastrar'),
                    onTap: () {
                      Navigator.pushNamed(context, '/vehicle-form');
                    },
                  ),
                ),

              SizedBox(height: 20),

              // Dashboard
              Text(
                'Dashboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              
              DashboardCard(
                title: 'Total Gasto',
                value: totalSpent,
                icon: Icons.attach_money,
                color: Colors.blue,
              ),
              SizedBox(height: 10),
              
              DashboardCard(
                title: vehicleVM.isFetchingFipe 
                    ? 'Buscando FIPE...' 
                    : 'Valor de Mercado (FIPE)',
                value: marketValue,
                icon: vehicleVM.isFetchingFipe ? Icons.refresh : Icons.price_check,
                color: vehicleVM.isFetchingFipe ? Colors.orange : Colors.green,
              ),
              
              if (tcoComparison != null && !vehicleVM.isFetchingFipe) ...[
                SizedBox(height: 10),
                DashboardCard(
                  title: '${tcoComparison > 0 ? 'Prejuízo' : 'Lucro'} (Gasto vs Mercado)',
                  value: tcoComparison.abs(),
                  icon: tcoComparison > 0 ? Icons.trending_down : Icons.trending_up,
                  color: tcoComparison > 0 ? Colors.red : Colors.green,
                ),
              ],

              SizedBox(height: 20),

              // Ações Rápidas
              Text(
                'Ações Rápidas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.add_chart),
                      label: Text('Novo Gasto'),
                      onPressed: () {
                        Navigator.pushNamed(context, '/expense-form');
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: vehicleVM.isFetchingFipe 
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Icon(Icons.update),
                      label: vehicleVM.isFetchingFipe 
                          ? Text('Consultando...')
                          : Text('Atualizar FIPE'),
                      onPressed: vehicleVM.isFetchingFipe ? null : () async {
                        if (vehicleVM.vehicle != null) {
                          await vehicleVM.fetchFipeValue();
                        }
                      },
                    ),
                  ),
                ],
              ),

              // Despesas recentes (SOMENTE se houver espaço)
              if (expenseVM.expenses.isNotEmpty && !vehicleVM.isFetchingFipe) ...[
                SizedBox(height: 20),
                Text(
                  'Despesas Recentes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ...expenseVM.expenses.take(2).map((expense) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Card(
                    child: ListTile(
                      leading: Icon(expense.category.icon),
                      title: Text(expense.description),
                      subtitle: Text('${expense.category.name} • ${expense.date.day}/${expense.date.month}/${expense.date.year}'),
                      trailing: Text(
                        'R\$${expense.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: expense.category == ExpenseCategory.tax ? Colors.red : Colors.orange,
                        ),
                      ),
                    ),
                  ),
                )).toList(),
                
                if (expenseVM.expenses.length > 2)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/history');
                        },
                        child: Text('Ver histórico completo (${expenseVM.expenses.length})'),
                      ),
                    ),
                  ),
              ],

              // Espaço final para garantir que não corte
              SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}