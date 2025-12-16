import '../models/expense.dart';
import '../utils/database_helper.dart';

class ExpenseService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertExpense(Expense expense) async {
    return await _dbHelper.insertExpense(expense);
  }

  Future<List<Expense>> getExpenses() async {
    return await _dbHelper.getExpenses();
  }

  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async {
    return await _dbHelper.getExpensesByCategory(category);
  }

  Future<int> deleteExpense(int id) async {
    return await _dbHelper.deleteExpense(id);
  }
}