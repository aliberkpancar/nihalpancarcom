import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart'
    if (dart.library.ffi) 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('orders.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    if (!kIsWeb && Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_no INTEGER UNIQUE,
        order_date TEXT,
        name TEXT,
        profile_name TEXT,
        phone TEXT,
        address TEXT,
        city TEXT,
        product_info TEXT,
        color TEXT,
        unit_price REAL,
        quantity INTEGER,
        total_price REAL,
        payment_status TEXT,
        shipping_status TEXT,
        shipping_date TEXT,
        shipping_code TEXT,
        note TEXT
      )
    ''');
  }

  Future<void> insertOrder(Map<String, dynamic> order) async {
    final db = await instance.database;

    final result = await db.rawQuery('SELECT MAX(order_no) as max_no FROM orders');
    final lastNo = result.first['max_no'] as int?;
    final newOrderNo = (lastNo ?? 1000) + 1;

    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    order['order_no'] = newOrderNo;
    order['order_date'] = today;

    await db.insert('orders', order);
  }

  Future<List<Map<String, dynamic>>> searchOrders(String keyword) async {
    final db = await instance.database;
    return await db.query(
      'orders',
      where: '''
        LOWER(name) LIKE ? OR
        LOWER(profile_name) LIKE ? OR
        LOWER(city) LIKE ? OR
        LOWER(product_info) LIKE ? OR
        LOWER(order_no) LIKE ?
      ''',
      whereArgs: List.filled(5, '%${keyword.toLowerCase()}%'),
    );
  }
}
