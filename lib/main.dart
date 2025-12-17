import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'views/home_screen.dart';
import 'views/vehicle_form_screen.dart';
import 'views/expense_form_screen.dart';
import 'views/history_screen.dart';
import 'viewmodels/vehicle_viewmodel.dart';
import 'viewmodels/expense_viewmodel.dart';
import 'models/vehicle.dart';
import 'models/expense.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // INICIALIZAÇÃO HIVE
  await Hive.initFlutter();
  
  // Registrar adaptadores (simplificado - sem .g.dart por enquanto)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(VehicleAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ExpenseCategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ExpenseAdapter());
  }
  
  // Abrir caixas
  await Hive.openBox<Vehicle>('vehicles');
  await Hive.openBox<Expense>('expenses');
  
  print('✅ Hive inicializado com sucesso!');
  
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
        
        // ROTAS com tratamento de argumentos
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => HomeScreen());
            
            case '/vehicle-form':
              final vehicle = settings.arguments as Vehicle?;
              return MaterialPageRoute(
                builder: (_) => VehicleFormScreen(vehicle: vehicle),
              );
            
            case '/expense-form':
              final expense = settings.arguments as Expense?;
              return MaterialPageRoute(
                builder: (_) => ExpenseFormScreen(expense: expense),
              );
            
            case '/history':
              return MaterialPageRoute(builder: (_) => HistoryScreen());
            
            default:
              return MaterialPageRoute(builder: (_) => HomeScreen());
          }
        },
        
        
        routes: {
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}