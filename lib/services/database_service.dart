import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/receipt_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  /// Get database instance, initializing if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database and create tables
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'huduma_receipt.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  /// Create database tables
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE receipts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        receiptNumber TEXT UNIQUE NOT NULL,
        vendorName TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        paymentMethod TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_date ON receipts(date DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_category ON receipts(category)
    ''');

    await db.execute('''
      CREATE INDEX idx_vendor ON receipts(vendorName)
    ''');
  }

  // ============ CREATE ============

  /// Insert a new receipt into the database
  Future<int> insertReceipt(Receipt receipt) async {
    final db = await database;
    try {
      final id = await db.insert(
        'receipts',
        receipt.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      throw Exception('Failed to insert receipt: $e');
    }
  }

  // ============ READ ============

  /// Get all receipts from the database
  Future<List<Receipt>> getAllReceipts() async {
    final db = await database;
    try {
      final result = await db.query(
        'receipts',
        orderBy: 'date DESC',
      );
      return result.map((map) => Receipt.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch receipts: $e');
    }
  }

  /// Get a single receipt by ID
  Future<Receipt?> getReceiptById(int id) async {
    final db = await database;
    try {
      final result = await db.query(
        'receipts',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (result.isEmpty) return null;
      return Receipt.fromMap(result.first);
    } catch (e) {
      throw Exception('Failed to fetch receipt: $e');
    }
  }

  /// Get receipts by category
  Future<List<Receipt>> getReceiptsByCategory(String category) async {
    final db = await database;
    try {
      final result = await db.query(
        'receipts',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'date DESC',
      );
      return result.map((map) => Receipt.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch receipts by category: $e');
    }
  }

  /// Get receipts by vendor name
  Future<List<Receipt>> getReceiptsByVendor(String vendorName) async {
    final db = await database;
    try {
      final result = await db.query(
        'receipts',
        where: 'vendorName LIKE ?',
        whereArgs: ['%$vendorName%'],
        orderBy: 'date DESC',
      );
      return result.map((map) => Receipt.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch receipts by vendor: $e');
    }
  }

  /// Get receipts within a date range
  Future<List<Receipt>> getReceiptsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    try {
      final result = await db.query(
        'receipts',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: 'date DESC',
      );
      return result.map((map) => Receipt.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch receipts by date range: $e');
    }
  }

  /// Get receipts by amount range
  Future<List<Receipt>> getReceiptsByAmountRange(
    double minAmount,
    double maxAmount,
  ) async {
    final db = await database;
    try {
      final result = await db.query(
        'receipts',
        where: 'amount BETWEEN ? AND ?',
        whereArgs: [minAmount, maxAmount],
        orderBy: 'amount DESC',
      );
      return result.map((map) => Receipt.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to fetch receipts by amount range: $e');
    }
  }

  /// Search receipts by receipt number or vendor name
  Future<List<Receipt>> searchReceipts(String query) async {
    final db = await database;
    try {
      final result = await db.query(
        'receipts',
        where: 'receiptNumber LIKE ? OR vendorName LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'date DESC',
      );
      return result.map((map) => Receipt.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to search receipts: $e');
    }
  }

  /// Get total amount spent
  Future<double> getTotalAmount() async {
    final db = await database;
    try {
      final result = await db.rawQuery('SELECT SUM(amount) as total FROM receipts');
      if (result.isEmpty) return 0.0;
      final total = result.first['total'];
      return total != null ? (total as num).toDouble() : 0.0;
    } catch (e) {
      throw Exception('Failed to get total amount: $e');
    }
  }

  /// Get total amount by category
  Future<Map<String, double>> getTotalAmountByCategory() async {
    final db = await database;
    try {
      final result = await db.rawQuery(
        'SELECT category, SUM(amount) as total FROM receipts GROUP BY category',
      );
      final map = <String, double>{};
      for (final row in result) {
        final category = row['category'] as String;
        final total = row['total'] as num?;
        map[category] = total?.toDouble() ?? 0.0;
      }
      return map;
    } catch (e) {
      throw Exception('Failed to get totals by category: $e');
    }
  }

  /// Get receipt count
  Future<int> getReceiptCount() async {
    final db = await database;
    try {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM receipts');
      if (result.isEmpty) return 0;
      return (result.first['count'] as num?)?.toInt() ?? 0;
    } catch (e) {
      throw Exception('Failed to get receipt count: $e');
    }
  }

  // ============ UPDATE ============

  /// Update an existing receipt
  Future<bool> updateReceipt(Receipt receipt) async {
    final db = await database;
    try {
      final updatedReceipt = receipt.copyWith(updatedAt: DateTime.now());
      final result = await db.update(
        'receipts',
        updatedReceipt.toMap(),
        where: 'id = ?',
        whereArgs: [receipt.id],
      );
      return result > 0;
    } catch (e) {
      throw Exception('Failed to update receipt: $e');
    }
  }

  // ============ DELETE ============

  /// Delete a receipt by ID
  Future<bool> deleteReceipt(int id) async {
    final db = await database;
    try {
      final result = await db.delete(
        'receipts',
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete receipt: $e');
    }
  }

  /// Delete all receipts
  Future<bool> deleteAllReceipts() async {
    final db = await database;
    try {
      final result = await db.delete('receipts');
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete all receipts: $e');
    }
  }

  /// Delete receipts by category
  Future<bool> deleteReceiptsByCategory(String category) async {
    final db = await database;
    try {
      final result = await db.delete(
        'receipts',
        where: 'category = ?',
        whereArgs: [category],
      );
      return result > 0;
    } catch (e) {
      throw Exception('Failed to delete receipts by category: $e');
    }
  }

  // ============ UTILITY ============

  /// Close database connection
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Clear and reinitialize database (useful for testing/reset)
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'huduma_receipt.db');
    await deleteDatabase(path);
    _database = null;
  }
}
