import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'views/home_screen.dart';
import 'views/vehicle_form_screen.dart';
import 'viewmodels/vehicle_viewmodel.dart';
import 'viewmodels/expense_viewmodel.dart';
import 'views/expense_form_screen.dart';

void main() {
  // Inicializa o FFI apenas se for web/desktop
  // Em mobile, essa linha não causa problemas
  sqfliteFfiInit();
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VehicleViewModel()),
        ChangeNotifierProvider(create: (_) => ExpenseViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AutoStats',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: HomeScreen(),
        routes: {
          '/history': (context) => Placeholder(),
          '/vehicle-form': (context) => VehicleFormScreen(),
          '/expense-form': (context) => ExpenseFormScreen(),
        },
      ),
    );
  }
}