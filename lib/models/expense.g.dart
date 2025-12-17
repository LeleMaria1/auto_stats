// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 2;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as int?,
      date: fields[1] as DateTime,
      category: ExpenseCategory.values[fields[2] as int],
      description: fields[3] as String,
      value: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.category.index)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.value);
  }
}

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 1;

  @override
  ExpenseCategory read(BinaryReader reader) {
    return ExpenseCategory.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    writer.writeByte(obj.index);
  }
}