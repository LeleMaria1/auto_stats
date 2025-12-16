import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/vehicle.dart';
import 'models/expense.dart';
import 'viewmodels/vehicle_viewmodel.dart';
import 'viewmodels/expense_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
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
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
        routes: {
          '/history': (context) => Placeholder(),
          '/vehicle-form': (context) => Placeholder(),
          '/expense-form': (context) => Placeholder(),
        },
      ),
    );
  }
}