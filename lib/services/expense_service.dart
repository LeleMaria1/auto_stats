import 'package:hive/hive.dart';
import '../models/expense.dart';

class ExpenseService {
  Box<Expense> get _expenseBox => Hive.box<Expense>('expenses');
  
  int _getNextId() {
    final box = _expenseBox;
    if (box.isEmpty) return 1;
    final maxId = box.values.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b);
    return maxId + 1;
  }

  Future<int> insertExpense(Expense expense) async {
    final box = _expenseBox;
    if (expense.id == null) {
      expense.id = _getNextId();
    }
    await box.put(expense.id, expense);
    return expense.id!;
  }

  // NOVO: Método para atualizar despesa existente
  Future<int> updateExpense(Expense expense) async {
    if (expense.id == null) return 0;
    await _expenseBox.put(expense.id, expense);
    return 1;
  }

  Future<List<Expense>> getExpenses() async {
    final box = _expenseBox;
    return box.values.toList().reversed.toList(); // Mais recentes primeiro
  }

  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async {
    final box = _expenseBox;
    return box.values
        .where((expense) => expense.category == category)
        .toList()
        .reversed
        .toList();
  }

  Future<int> deleteExpense(int id) async {
    await _expenseBox.delete(id);
    return 1;
  }
}