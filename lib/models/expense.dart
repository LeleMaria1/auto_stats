import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 1)
enum ExpenseCategory {
  @HiveField(0)
  fuel,
  
  @HiveField(1)
  maintenance,
  
  @HiveField(2)
  tax,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get name {
    switch (this) {
      case ExpenseCategory.fuel:
        return 'Abastecimento/Recarga';
      case ExpenseCategory.maintenance:
        return 'Manutenção';
      case ExpenseCategory.tax:
        return 'Impostos';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.fuel:
        return Icons.local_gas_station;
      case ExpenseCategory.maintenance:
        return Icons.build;
      case ExpenseCategory.tax:
        return Icons.receipt;
    }
  }
}

@HiveType(typeId: 2)
class Expense {
  @HiveField(0)
  int? id;
  
  @HiveField(1)
  DateTime date;
  
  @HiveField(2)
  ExpenseCategory category;
  
  @HiveField(3)
  String description;
  
  @HiveField(4)
  double value;

  Expense({
    this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.value,
  });
}