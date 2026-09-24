import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../../models/category.dart';

/// قاعدة البيانات المحلية للنظام — SQLite عبر FFI (Windows/Linux/macOS)
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;
  static const int _version = 3;
  static const String _dbName = 'foodpro.db';
  static const _uuid = Uuid();

  /// الحصول على مثيل قاعدة البيانات (Lazy init)
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    // تهيئة FFI لـ Windows/Desktop
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final appDir = await getApplicationSupportDirectory();
    final dbPath = p.join(appDir.path, _dbName);

    return await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
          await db.execute('PRAGMA journal_mode = WAL');
        },
      ),
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE products ADD COLUMN icon TEXT');
    }
    if (oldVersion < 3) {
      // إضافة حسابات owner و cashier الافتراضية إذا لم تكن موجودة
      await _seedDefaultAccounts(db);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // ── جدول التصنيفات ─────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE categories (
        id        TEXT PRIMARY KEY,
        name      TEXT NOT NULL,
        color_hex TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // ── جدول الأصناف ───────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE products (
        id          TEXT PRIMARY KEY,
        category_id TEXT NOT NULL,
        name        TEXT NOT NULL,
        price       REAL NOT NULL,
        cost        REAL,
        stock       REAL NOT NULL DEFAULT 0,
        min_stock   REAL NOT NULL DEFAULT 0,
        unit        TEXT NOT NULL DEFAULT 'وحدة',
        icon        TEXT,
        is_active   INTEGER NOT NULL DEFAULT 1,
        created_at  TEXT NOT NULL,
        updated_at  TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_products_category ON products(category_id)',
    );
    await db.execute('CREATE INDEX idx_products_active ON products(is_active)');

    // ── جدول الطلبات ───────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE orders (
        id              TEXT PRIMARY KEY,
        order_number    TEXT NOT NULL UNIQUE,
        user_id         TEXT,
        user_name       TEXT,
        subtotal        REAL NOT NULL,
        discount_amount REAL NOT NULL DEFAULT 0,
        final_amount    REAL NOT NULL,
        paid_amount     REAL NOT NULL,
        change_amount   REAL NOT NULL DEFAULT 0,
        payment_method  TEXT NOT NULL,
        payment_ref     TEXT,
        status          TEXT NOT NULL DEFAULT 'completed',
        notes           TEXT,
        created_at      TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_orders_date ON orders(created_at)');
    await db.execute('CREATE INDEX idx_orders_status ON orders(status)');

    // ── جدول عناصر الطلبات ─────────────────────────────────────────
    await db.execute('''
      CREATE TABLE order_items (
        id           TEXT PRIMARY KEY,
        order_id     TEXT NOT NULL,
        product_id   TEXT NOT NULL,
        product_name TEXT NOT NULL,
        unit_price   REAL NOT NULL,
        quantity     REAL NOT NULL,
        total_price  REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_order_items_order ON order_items(order_id)',
    );

    // ── جدول حركة المخزون ──────────────────────────────────────────
    await db.execute('''
      CREATE TABLE stock_movements (
        id           TEXT PRIMARY KEY,
        product_id   TEXT NOT NULL,
        product_name TEXT NOT NULL,
        type         TEXT NOT NULL,
        quantity     REAL NOT NULL,
        stock_before REAL NOT NULL,
        stock_after  REAL NOT NULL,
        order_id     TEXT,
        reason       TEXT,
        notes        TEXT,
        user_id      TEXT,
        created_at   TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_stock_product ON stock_movements(product_id)',
    );

    // ── جدول المصروفات ─────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE expenses (
        id          TEXT PRIMARY KEY,
        category    TEXT NOT NULL,
        amount      REAL NOT NULL,
        description TEXT,
        user_id     TEXT,
        date        TEXT NOT NULL,
        created_at  TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');

    // ── جدول المستخدمين ────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE users (
        id         TEXT PRIMARY KEY,
        name       TEXT NOT NULL,
        username   TEXT NOT NULL UNIQUE,
        pin        TEXT NOT NULL,
        role       TEXT NOT NULL DEFAULT 'cashier',
        is_active  INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // ── جدول الإعدادات ─────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE settings (
        key   TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // ── البيانات الابتدائية ──────────────────────────────────────────
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // إعدادات المطعم الافتراضية
    final defaultSettings = {
      'restaurant_name': 'مطعمي',
      'restaurant_phone': '',
      'restaurant_address': '',
      'currency': 'ج.م',
      'tax_rate': '0',
      'order_counter': '0',
    };
    for (final entry in defaultSettings.entries) {
      await db.insert('settings', {'key': entry.key, 'value': entry.value});
    }

    // مستخدم المدير الافتراضي (admin القديم)
    final managerId = _uuid.v4();
    await db.insert('users', {
      'id': managerId,
      'name': 'مدير النظام',
      'username': 'admin',
      'pin': '1234',
      'role': 'manager',
      'is_active': 1,
      'created_at': now,
    });

    // إضافة الحسابات الافتراضية الجديدة
    await _seedDefaultAccounts(db);

    // تم إزالة التصنيفات الافتراضية بناءً على طلب العميل
    // المستخدم هو من سيقوم بإضافة التصنيفات والمنتجات بنفسه
  }

  /// إضافة حسابات owner و cashier إذا لم تكن موجودة
  Future<void> _seedDefaultAccounts(Database db) async {
    final now = DateTime.now().toIso8601String();

    // التحقق من وجود owner قبل إضافته
    final ownerCheck = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['owner'],
    );
    if (ownerCheck.isEmpty) {
      await db.insert('users', {
        'id': _uuid.v4(),
        'name': 'صاحب المطعم',
        'username': 'owner',
        'pin': 'owner1234',
        'role': 'manager',
        'is_active': 1,
        'created_at': now,
      });
    }

    // التحقق من وجود cashier قبل إضافته
    final cashierCheck = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['cashier'],
    );
    if (cashierCheck.isEmpty) {
      await db.insert('users', {
        'id': _uuid.v4(),
        'name': 'الكاشير',
        'username': 'cashier',
        'pin': '1234',
        'role': 'cashier',
        'is_active': 1,
        'created_at': now,
      });
    }
  }

  /// توليد ID فريد
  static String generateId() => _uuid.v4();

  /// ─── عمليات عامة ────────────────────────────────────────────────

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? args,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, args);
  }

  Future<void> runTransaction(
    Future<void> Function(Transaction txn) action,
  ) async {
    final db = await database;
    await db.transaction(action);
  }

  /// ─── الإعدادات ──────────────────────────────────────────────────
  Future<void> deleteAllSales({bool resetOrderCounter = true}) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('orders');
      if (resetOrderCounter) {
        await txn.insert('settings', {
          'key': 'order_counter',
          'value': '0',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<String?> getSetting(String key) async {
    final results = await query('settings', where: 'key = ?', whereArgs: [key]);
    if (results.isEmpty) return null;
    return results.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// ─── رقم الطلب التسلسلي ─────────────────────────────────────────

  Future<String> generateOrderNumber() async {
    final db = await database;
    final counterStr = await getSetting('order_counter') ?? '0';
    final counter = (int.tryParse(counterStr) ?? 0) + 1;
    await db.insert('settings', {
      'key': 'order_counter',
      'value': counter.toString(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return counter.toString().padLeft(6, '0');
  }

  /// ─── التصنيفات ────────────────────────────────────────────────────

  Future<List<Category>> getCategories({bool activeOnly = true}) async {
    final results = await query(
      'categories',
      where: activeOnly ? 'is_active = 1' : null,
      orderBy: 'created_at ASC',
    );
    return results.map(Category.fromMap).toList();
  }

  Future<void> closeDatabase() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
