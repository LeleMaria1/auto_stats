import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseViewModel with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  double get totalExpenses => _expenses.fold(0, (sum, expense) => sum + expense.value);

  void setExpenses(List<Expense> expenses) {
    _expenses = expenses;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Adicionar despesa (simulado por enquanto)
  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    notifyListeners();
  }

  // Para teste inicial: dados mockados
  void loadMockData() {
    _expenses = [
      Expense(
        id: 1,
        date: DateTime.now().subtract(Duration(days: 10)),
        category: ExpenseCategory.fuel,
        description: 'Abastecimento',
        value: 250.0,
      ),
      Expense(
        id: 2,
        date: DateTime.now().subtract(Duration(days: 5)),
        category: ExpenseCategory.maintenance,
        description: 'Troca de óleo',
        value: 180.0,
      ),
      Expense(
        id: 3,
        date: DateTime.now().subtract(Duration(days: 2)),
        category: ExpenseCategory.tax,
        description: 'IPVA',
        value: 1200.0,
      ),
    ];
    notifyListeners();
  }
}