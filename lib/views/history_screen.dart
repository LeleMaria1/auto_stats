import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/expense.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  ExpenseCategory? _selectedFilter;
  DateTimeRange? _dateRange;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange ?? DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 30)),
        end: DateTime.now(),
      ),
    );
    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedFilter = null;
      _dateRange = null;
    });
  }

  double _calculateFilteredTotal(List<Expense> expenses) {
    var filtered = expenses;
    
    if (_selectedFilter != null) {
      filtered = filtered.where((e) => e.category == _selectedFilter).toList();
    }
    
    if (_dateRange != null) {
      filtered = filtered.where((e) => 
        e.date.isAfter(_dateRange!.start.subtract(Duration(days: 1))) &&
        e.date.isBefore(_dateRange!.end.add(Duration(days: 1)))
      ).toList();
    }
    
    return filtered.fold(0, (sum, expense) => sum + expense.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Despesas'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildFilterSheet(context),
              );
            },
          ),
        ],
      ),
      body: Consumer<ExpenseViewModel>(
        builder: (context, expenseVM, child) {
          if (expenseVM.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final expenses = expenseVM.expenses;
          final filteredTotal = _calculateFilteredTotal(expenses);
          var filteredExpenses = expenses;

          // Aplicar filtros
          if (_selectedFilter != null) {
            filteredExpenses = filteredExpenses
                .where((e) => e.category == _selectedFilter)
                .toList();
          }

          if (_dateRange != null) {
            filteredExpenses = filteredExpenses
                .where((e) => 
                  e.date.isAfter(_dateRange!.start.subtract(Duration(days: 1))) &&
                  e.date.isBefore(_dateRange!.end.add(Duration(days: 1)))
                )
                .toList();
          }

          return Column(
            children: [
              // Resumo
              Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Filtrado',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'R\$${filteredTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_selectedFilter != null || _dateRange != null)
                        TextButton(
                          onPressed: _clearFilters,
                          child: Text('Limpar Filtros'),
                        ),
                    ],
                  ),
                ),
              ),

              // Lista de despesas
              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Nenhuma despesa encontrada',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            if (_selectedFilter != null || _dateRange != null)
                              TextButton(
                                onPressed: _clearFilters,
                                child: Text('Limpar filtros'),
                              ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = filteredExpenses[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getCategoryColor(expense.category),
                                child: Icon(
                                  expense.category.icon,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(expense.description),
                              subtitle: Text(
                                '${expense.category.name} • ${_dateFormat.format(expense.date)}',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'R\$${expense.value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (expense.category == ExpenseCategory.tax)
                                    Text(
                                      'Imposto',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/expense-form',
                                  arguments: expense,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSheet(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          
          // Filtro de categoria
          Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text('Todos'),
                selected: _selectedFilter == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = null;
                  });
                  Navigator.pop(context);
                },
              ),
              ...ExpenseCategory.values.map((category) {
                return FilterChip(
                  label: Text(category.name),
                  selected: _selectedFilter == category,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? category : null;
                    });
                    Navigator.pop(context);
                  },
                  avatar: Icon(category.icon, size: 18),
                );
              }).toList(),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Filtro de data
          Text('Período', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          OutlinedButton.icon(
            icon: Icon(Icons.calendar_today),
            label: Text(
              _dateRange == null
                  ? 'Selecionar período'
                  : '${_dateFormat.format(_dateRange!.start)} - ${_dateFormat.format(_dateRange!.end)}',
            ),
            onPressed: () {
              Navigator.pop(context);
              _selectDateRange(context);
            },
          ),
          
          SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  _clearFilters();
                  Navigator.pop(context);
                },
                child: Text('Limpar tudo'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Aplicar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.fuel:
        return Colors.blue;
      case ExpenseCategory.maintenance:
        return Colors.orange;
      case ExpenseCategory.tax:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}