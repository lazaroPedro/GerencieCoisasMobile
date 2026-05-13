import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBConfig {
  static final DBConfig instance = DBConfig._init();
  static Database? _database;

  DBConfig._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);

  }

  Future _createDB(Database db, int version) async {
    final scriptCompleto = await rootBundle.loadString('assets/db/schema.sql');
  
    final comandos = scriptCompleto.split(';');


    final batch = db.batch();
  
    for (var comando in comandos) {
      final comandoLimpo = comando.trim();
      if (comandoLimpo.isNotEmpty) {
        batch.execute(comandoLimpo);
      }
    }
  

    await batch.commit(noResult: true);
  }
}