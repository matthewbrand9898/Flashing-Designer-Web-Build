import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:sembast_web/sembast_web.dart';
import 'package:flashing_designer/models/order_model.dart';

class OrderStorage {
  static const _dbName = 'orders.db';
  static const _storeName = 'orders';

  static Database? _db;
  static bool _persistenceRequested = false;
  static final StoreRef<int, Map<String, dynamic>> _store =
      intMapStoreFactory.store(_storeName);

  /// Requests persistent storage; returns `true` if granted.
  static Future<bool> requestPersistentStorage() async {
    final storage = web.window.navigator.storage;
    return await storage.persist().toDart as bool;
  }

  /// Opens (or reuses) the IndexedDB database.
  /// Automatically requests persistent storage on first call.
  static Future<Database> _openDb() async {
    if (!_persistenceRequested) {
      _persistenceRequested = true;
      // Fire the request and ignore its result—no unused variable!
      await requestPersistentStorage();
    }
    if (_db != null) return _db!;
    _db = await databaseFactoryWeb.openDatabase(_dbName);
    return _db!;
  }

  /// Reads all orders from IndexedDB.
  static Future<List<Order>> readOrders() async {
    final db = await _openDb();
    final records = await _store.find(db);
    return records.map((r) => Order.fromJson(r.value)).toList();
  }

  /// Overwrites the “orders” store with the provided list.
  static Future<void> writeOrders(List<Order> orders) async {
    final db = await _openDb();
    await _store.delete(db);
    final data = orders.map((o) => o.toJson()).toList();
    await _store.addAll(db, data);
  }
}
