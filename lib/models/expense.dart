import 'package:flutter/material.dart';

enum ExpenseCategory {
  fuel,
  maintenance,
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
      default:
        return 'Outro';
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
      default:
        return Icons.money;
    }
  }
}

class Expense {
  int? id;
  DateTime date;
  ExpenseCategory category;
  String description;
  double value;

  Expense({
    this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'category': category.index,
      'description': description,
      'value': value,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      date: DateTime.parse(map['date']),
      category: ExpenseCategory.values[map['category']],
      description: map['description'],
      value: map['value'],
    );
  }
}