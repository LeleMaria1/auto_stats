import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> initDatabase() async {
  // Inicializa o FFI para plataformas que não são Android/iOS
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  print('✅ Banco de dados inicializado com FFI');
}