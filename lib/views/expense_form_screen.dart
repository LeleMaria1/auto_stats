import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/expense_viewmodel.dart';
import '../models/expense.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;

  ExpenseFormScreen({this.expense});

  @override
  _ExpenseFormScreenState createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  ExpenseCategory _selectedCategory = ExpenseCategory.fuel;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _descriptionController.text = widget.expense!.description;
      _valueController.text = widget.expense!.value.toStringAsFixed(2);
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExpense(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final expenseVM = Provider.of<ExpenseViewModel>(context, listen: false);

    final expense = Expense(
      id: widget.expense?.id,
      date: _selectedDate,
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      value: double.parse(_valueController.text),
    );

    await expenseVM.addExpense(expense);

    if (expenseVM.errorMessage == null) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${expenseVM.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Nova Despesa' : 'Editar Despesa'),
      ),
      body: Consumer<ExpenseViewModel>(
        builder: (context, expenseVM, child) {
          if (expenseVM.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Categoria
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 8.0,
                            children: ExpenseCategory.values.map((category) {
                              return ChoiceChip(
                                label: Text(category.name),
                                selected: _selectedCategory == category,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                avatar: Icon(category.icon, size: 18),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Data
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('Data'),
                      subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                      trailing: Icon(Icons.arrow_drop_down),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Descrição
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe uma descrição';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Valor
                  TextFormField(
                    controller: _valueController,
                    decoration: InputDecoration(
                      labelText: 'Valor (R\$)',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Informe o valor';
                      }
                      final val = double.tryParse(value);
                      if (val == null || val <= 0) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // Botão Salvar
                  ElevatedButton(
                    onPressed: () => _saveExpense(context),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Salvar Despesa',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  // Exibir erro se houver
                  if (expenseVM.errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        expenseVM.errorMessage!,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}