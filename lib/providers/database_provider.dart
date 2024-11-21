import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider with ChangeNotifier {
  static final DatabaseProvider instance = DatabaseProvider._init();
  static Database? _database;

  DatabaseProvider._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cafe_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE MenuItem (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        price REAL,
        image TEXT
      )
    ''');
    await db.execute(''' 
      CREATE TABLE Subscriber (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');
    await db.execute(''' 
      CREATE TABLE OrderHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        subscriberId INTEGER,
        menuId INTEGER,
        item_name TEXT,
        date TEXT,
        quantity INTEGER,
        total_price REAL,
        FOREIGN KEY (subscriberId) REFERENCES Subscriber(id),
        FOREIGN KEY (menuId) REFERENCES MenuItem(id)
      )
    '''); 
    await db.execute('''
    CREATE TABLE InvoiceHistory(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      subscriberId INTEGER,
      date TEXT,
      total_amount REAL,
      subscriberName TEXT,
      additionalInfo TEXT
    );
  ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute(''' 
        ALTER TABLE OrderHistory ADD COLUMN item_name TEXT
      ''');
    }
    if (oldVersion < 2) {
      await db.execute(''' 
        ALTER TABLE OrderHistory ADD COLUMN total_price REAL
      ''');
    }
  }

  Future<int> deleteSubscriber(int id) async {
    final db = await database;
    return await db.delete(
      'Subscriber',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertMenuItem(Map<String, dynamic> row) async {
    final db = await instance.database;
    await db.insert('MenuItem', row, conflictAlgorithm: ConflictAlgorithm.replace);
    notifyListeners();
  }

  Future<void> insertSubscriber(String name) async {
    final db = await instance.database;
    await db.insert('Subscriber', {'name': name}, conflictAlgorithm: ConflictAlgorithm.replace);
    notifyListeners();
  }

  Future<void> insertOrderHistory(Map<String, dynamic> row) async {
    final db = await instance.database;
    await db.insert('OrderHistory', row, conflictAlgorithm: ConflictAlgorithm.replace);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getMenuItems() async {
    final db = await instance.database;
    return await db.query('MenuItem');
  }

  Future<List<Map<String, dynamic>>> getSubscribers() async {
    final db = await instance.database;
    return await db.query('Subscriber');
  }

  Future<List<Map<String, dynamic>>> getOrderHistory(int subscriberId) async {
    final db = await instance.database;
    return await db.query(
      'OrderHistory',
      where: 'subscriberId = ?',
      whereArgs: [subscriberId],
    );
  }

  Future<void> updateMenuItem(int id, Map<String, dynamic> newValues) async {
    final db = await instance.database;
    await db.update(
      'MenuItem',
      newValues,
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }

  Future<void> deleteMenuItem(int id) async {
    final db = await instance.database;
    await db.delete(
      'MenuItem',
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }

  Future<void> deleteOrderHistory(int subscriberId) async {
    final db = await instance.database;
    await db.delete(
      'OrderHistory',
      where: 'subscriberId = ?',
      whereArgs: [subscriberId],
    );
    notifyListeners();
  }

  Future<int> getTotalSubscribers() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM Subscriber');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getTotalOrderPrices() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(total_price) AS total FROM OrderHistory');
    return result.first['total'] as double? ?? 0.0;
  }

  Future<double> getWeeklyTotal() async {
    final db = await instance.database;
    final oneWeekAgo = DateTime.now().subtract(Duration(days: 7)).toIso8601String();
    final result = await db.rawQuery(
      '''SELECT SUM(total_price) AS weekly_total 
         FROM OrderHistory 
         WHERE date >= ?''',
      [oneWeekAgo],
    );
    return result.first['weekly_total'] as double? ?? 0.0;
  }

  Future<void> clearWeeklyHistory() async {
    final db = await instance.database;
    await db.delete('OrderHistory');
    notifyListeners();
  }

  Future<String> getSubscriberName(int subscriberId) async {
    final db = await instance.database;
    final result = await db.query(
      'Subscriber',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [subscriberId],
    );

    if (result.isNotEmpty) {
      return result.first['name'] as String;
    } else {
      return 'Unknown Subscriber';
    }
  }

  Future<void> insertInvoiceHistory(
      int subscriberId, String date, double totalAmount, String subscriberName, String additionalInfo) async {
    final db = await instance.database;
    await db.insert(
      'InvoiceHistory',
      {
        'subscriberId': subscriberId,
        'date': date,
        'total_amount': totalAmount,
        'subscriberName': subscriberName,
        'additionalInfo': additionalInfo,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getAllInvoiceHistory({int limit = 20, int offset = 0}) async {
    final db = await instance.database;
    return await db.query(
      'InvoiceHistory',
      limit: limit,
      offset: offset,
      orderBy: 'id DESC',
    );
  }

  Future<void> exportDatabase() async {
    final db = await instance.database;
    final menuItems = await db.query('MenuItem');
    final subscribers = await db.query('Subscriber');
    final orderHistory = await db.query('OrderHistory');
    final invoiceHistory = await db.query('InvoiceHistory');

    final databaseData = {
      'MenuItem': menuItems,
      'Subscriber': subscribers,
      'OrderHistory': orderHistory,
      'InvoiceHistory': invoiceHistory,
    };

    final jsonData = jsonEncode(databaseData);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/database_export.json';
    final file = File(filePath);

    await file.writeAsString(jsonData);
    print('Database exported to: $filePath');
  }

  Future<void> importDatabase() async {
    final db = await instance.database;
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/database_export.json';
    final file = File(filePath);

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> databaseData = jsonDecode(jsonString);

      await db.delete('MenuItem');
      await db.delete('Subscriber');
      await db.delete('OrderHistory');
      await db.delete('InvoiceHistory');

      await _insertData('MenuItem', databaseData['MenuItem']);
      await _insertData('Subscriber', databaseData['Subscriber']);
      await _insertData('OrderHistory', databaseData['OrderHistory']);
      await _insertData('InvoiceHistory', databaseData['InvoiceHistory']);

      print('Database imported successfully.');
    } else {
      print('No file found at $filePath');
    }
  }

  Future<void> _insertData(String table, List<Map<String, dynamic>> data) async {
    final db = await instance.database;
    for (var row in data) {
      await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
