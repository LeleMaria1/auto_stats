import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseViewModel with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalExpenses => _expenses.fold(0, (sum, expense) => sum + expense.value);

  final ExpenseService _expenseService = ExpenseService();

  ExpenseViewModel() {
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setLoading(true);
    try {
      _expenses = await _expenseService.getExpenses();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao carregar despesas: $e';
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    setLoading(true);
    try {
      final id = await _expenseService.insertExpense(expense);
      expense.id = id;
      _expenses.insert(0, expense);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao adicionar despesa: $e';
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> deleteExpense(int expenseId) async {
    setLoading(true);
    try {
      await _expenseService.deleteExpense(expenseId);
      _expenses.removeWhere((expense) => expense.id == expenseId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao excluir despesa: $e';
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<List<Expense>> getExpensesByCategory(int categoryIndex) async {
    try {
      return await _expenseService.getExpensesByCategory(
        ExpenseCategory.values[categoryIndex],
      );
    } catch (e) {
      _errorMessage = 'Erro ao filtrar despesas: $e';
      return [];
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