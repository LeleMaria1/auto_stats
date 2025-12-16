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
          if (vehicleVM.isLoading || expenseVM.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final totalSpent = expenseVM.totalExpenses;
          final marketValue = vehicleVM.marketValue ?? 0.0;
          final tcoComparison = marketValue > 0 ? totalSpent - marketValue : null;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Veículo atual
                if (vehicleVM.vehicle != null)
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.directions_car),
                      title: Text(vehicleVM.vehicle!.model),
                      subtitle: Text('${vehicleVM.vehicle!.year} • ${vehicleVM.vehicle!.currentMileage} km'),
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
                          IconButton(
                            icon: Icon(Icons.update),
                            onPressed: () => vehicleVM.fetchFipeValue(),
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
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 10),
                DashboardCard(
                  title: 'Total Gasto',
                  value: totalSpent,
                  icon: Icons.attach_money,
                  color: Colors.blue,
                ),
                DashboardCard(
                  title: 'Valor de Mercado (FIPE)',
                  value: marketValue,
                  icon: Icons.price_check,
                  color: Colors.green,
                ),
                if (tcoComparison != null)
                  DashboardCard(
                    title: 'Diferença (Gasto - Mercado)',
                    value: tcoComparison,
                    icon: Icons.compare,
                    color: tcoComparison > 0 ? Colors.red : Colors.green,
                  ),

                SizedBox(height: 20),

                // Ações Rápidas
                Text(
                  'Ações Rápidas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.add_chart),
                        label: Text('Novo Gasto'),
                        onPressed: () {
                          // CORREÇÃO: Navegação correta para expense-form
                          Navigator.pushNamed(
                            context,
                            '/expense-form',
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.update),
                        label: Text('Atualizar FIPE'),
                        onPressed: () {
                          if (vehicleVM.vehicle != null) {
                            vehicleVM.fetchFipeValue();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Cadastre um veículo primeiro')),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),

                // Seção de despesas recentes (opcional, para melhorar UX)
                if (expenseVM.expenses.isNotEmpty) ...[
                  SizedBox(height: 20),
                  Text(
                    'Despesas Recentes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 10),
                  Card(
                    child: Column(
                      children: expenseVM.expenses.take(3).map((expense) {
                        return ListTile(
                          leading: Icon(expense.category.icon),
                          title: Text(expense.description),
                          subtitle: Text('${expense.category.name} • ${expense.date.day}/${expense.date.month}/${expense.date.year}'),
                          trailing: Text(
                            'R\$${expense.value.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: expense.category == ExpenseCategory.tax
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (expenseVM.expenses.length > 3)
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/history');
                      },
                      child: Text('Ver todas as despesas (${expenseVM.expenses.length})'),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}