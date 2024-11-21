import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper with ChangeNotifier {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

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
      version: 3, // Adjust based on the latest version of your database
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // Creating tables when the database is first created
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
      subscriberName TEXT,        -- New column
      additionalInfo TEXT         -- New column
    );
  ''');
  
    
  }
  

  // Upgrade handling: Adds item_name and total_price if upgrading
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      // Adding item_name column in case of version upgrade
      await db.execute(''' 
        ALTER TABLE OrderHistory ADD COLUMN item_name TEXT
      ''');
      
    }
    if (oldVersion < 2) {
      // Adding total_price column if upgrading from version 1 to 2
      await db.execute(''' 
        ALTER TABLE OrderHistory ADD COLUMN total_price REAL
      ''');
    }
    notifyListeners();
  }
  Future<int> deleteSubscriber(int id) async {
  final db = await database;
  return await db.delete(
    'Subscriber',   // Updated to match the exact table name
    where: 'id = ?', // Condition to match the subscriber's ID
    whereArgs: [id], // Pass the ID as an argument
  );
  
}



  // Insert a new menu item
  Future<void> insertMenuItem(Map<String, dynamic> row) async {
    final db = await instance.database;
    await db.insert('MenuItem', row, conflictAlgorithm: ConflictAlgorithm.replace);
     notifyListeners();
  }

  // Insert a new subscriber
  Future<void> insertSubscriber(String name) async {
    final db = await instance.database;
    await db.insert('Subscriber', {'name': name}, conflictAlgorithm: ConflictAlgorithm.replace);
     notifyListeners();
  }

  // Insert an order history record
  Future<void> insertOrderHistory(Map<String, dynamic> row) async {
    final db = await instance.database;
    await db.insert('OrderHistory', row, conflictAlgorithm: ConflictAlgorithm.replace);
     notifyListeners();
  }

  // Get all menu items
  Future<List<Map<String, dynamic>>> getMenuItems() async {
    final db = await instance.database;
    return await db.query('MenuItem');
     
  }

  // Get all subscribers
  Future<List<Map<String, dynamic>>> getSubscribers() async {
    final db = await instance.database;
    return await db.query('Subscriber');
    
  }

  // Get order history for a specific subscriber
  Future<List<Map<String, dynamic>>> getOrderHistory(int subscriberId) async {
    final db = await instance.database;
    return await db.query(
      'OrderHistory',
      where: 'subscriberId = ?',
      whereArgs: [subscriberId],
    );
    
  }

  // Update a menu item
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

  // Delete a menu item
  Future<void> deleteMenuItem(int id) async {
    final db = await instance.database;
    await db.delete(
      'MenuItem',
      where: 'id = ?',
      whereArgs: [id],
    );
     notifyListeners();
  }

  // Delete order history for a specific subscriber
  Future<void> deleteOrderHistory(int subscriberId) async {
    final db = await instance.database;
    await db.delete(
      'OrderHistory',
      where: 'subscriberId = ?',
      whereArgs: [subscriberId],
    );
     notifyListeners();
  }

  // Get total subscribers count
  Future<int> getTotalSubscribers() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) AS count FROM Subscriber');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get total order prices
  Future<double> getTotalOrderPrices() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(total_price) AS total FROM OrderHistory');
    return result.first['total'] as double? ?? 0.0;
  }

  // Calculate weekly total
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

  // Clear historical data after marking as done
  Future<void> clearWeeklyHistory() async {
    final db = await instance.database;
    await db.delete('OrderHistory');
     notifyListeners();
  }


   // Function to fetch subscriber name by ID
  Future<String> getSubscriberName(int subscriberId) async {
    final db = await instance.database;

    // Assuming 'subscribers' is the table name and 'name' is the column storing subscriber names
    final result = await db.query(
      'Subscriber', // table name
      columns: ['name'], // columns to select
      where: 'id = ?', // selection criteria
      whereArgs: [subscriberId], // value for selection criteria
    );

    if (result.isNotEmpty) {
      // Return the name of the subscriber
      return result.first['name'] as String;
    } else {
      // If no subscriber found, return a default or empty string
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
      'subscriberName': subscriberName,  // Insert subscriber name
      'additionalInfo': additionalInfo,  // Insert additional info
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
   notifyListeners();
}



// Fetch all invoices for all subscribers
Future<List<Map<String, dynamic>>> getAllInvoiceHistory({int limit = 20, int offset = 0}) async {
  final db = await instance.database;
  return await db.query(
    'InvoiceHistory',
    limit: limit,
    offset: offset,
    orderBy: 'id DESC',
  );
  
}


////////////////////////////////////////////////////////////////////////////////////////
Future<void> exportDatabase() async {
  final db = await instance.database;

  // Fetch all data from the tables
  final menuItems = await db.query('MenuItem');
  final subscribers = await db.query('Subscriber');
  final orderHistory = await db.query('OrderHistory');
  final invoiceHistory = await db.query('InvoiceHistory');

  // Create a Map to hold all the data
  final databaseData = {
    'MenuItem': menuItems,
    'Subscriber': subscribers,
    'OrderHistory': orderHistory,
    'InvoiceHistory': invoiceHistory,
  };

  // Convert the data to JSON
  final jsonData = jsonEncode(databaseData);

  // Get the directory to store the exported file
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/database_export.json';
  final file = File(filePath);

  // Write the data to a file
  await file.writeAsString(jsonData);

  print('Database exported to: $filePath');
}
///////////////////////////////////////////////////////////////////////////////////////
Future<void> importDatabase() async {
  final db = await instance.database;

  // Get the path to the import file
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/database_export.json';
  final file = File(filePath);

  // Read the file and parse the JSON
  if (await file.exists()) {
    final jsonString = await file.readAsString();
    final Map<String, dynamic> databaseData = jsonDecode(jsonString);

    // Clear the existing data before importing (optional)
    await db.delete('MenuItem');
    await db.delete('Subscriber');
    await db.delete('OrderHistory');
    await db.delete('InvoiceHistory');

    // Insert data back into the respective tables
    await _insertData('MenuItem', databaseData['MenuItem']);
    await _insertData('Subscriber', databaseData['Subscriber']);
    await _insertData('OrderHistory', databaseData['OrderHistory']);
    await _insertData('InvoiceHistory', databaseData['InvoiceHistory']);

    print('Database imported successfully.');
  } else {
    print('No file found at $filePath');
  }
}

// Helper method to insert data into a table
Future<void> _insertData(String table, List<Map<String, dynamic>> data) async {
  final db = await instance.database;
  for (var row in data) {
    await db.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

////////////////////////////////////////////////////////////////////////////////////////


  // Close the database connection
  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
