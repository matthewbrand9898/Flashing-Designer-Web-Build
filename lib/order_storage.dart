import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'package:sembast_web/sembast_web.dart';
import 'package:flashing_designer/models/order_model.dart';

class OrderStorage {
  static const _dbName = 'orders.db';
  static const _storeName = 'orders';

  static Database? _db;
  static bool _persistenceRequested = false;

  // String‑keyed store
  static final StoreRef<String, Map<String, dynamic>> _store =
      stringMapStoreFactory.store(_storeName);

  /// Open (or reuse) the DB, asking for persistence once.
  static Future<Database> _openDb() async {
    if (!_persistenceRequested) {
      _persistenceRequested = true;
      // fire‑and‑forget persistence request
      await web.window.navigator.storage.persist().toDart;
    }
    if (_db != null) return _db!;
    _db = await databaseFactoryWeb.openDatabase(_dbName);
    return _db!;
  }

  /// Read all orders.  Assumes each record’s JSON already has the correct `id` field.
  static Future<List<Order>> readOrders() async {
    final db = await _openDb();
    final records = await _store.find(db);
    return records.map((r) => Order.fromJson(r.value)).toList();
  }

  /// Insert or update a single order.
  /// **Precondition:** `order.id` is non‑empty.
  static Future<void> saveOrder(Order order) async {
    final db = await _openDb();
    if (order.id.isEmpty) {
      throw ArgumentError.value(order.id, 'order.id', 'must be non‑empty');
    }
    await _store.record(order.id).put(db, order.toJson());
  }

  /// Delete one order by its string key.
  static Future<void> deleteOrder(String id) async {
    final db = await _openDb();
    await _store.record(id).delete(db);
  }

  /// Bulk sync: upsert all incoming orders, delete any others in the store.
  /// **Precondition:** every `o.id` in [orders] is non‑empty.
  static Future<void> syncOrders(List<Order> orders) async {
    final db = await _openDb();

    // Pre‑validate
    for (var o in orders) {
      if (o.id.isEmpty) {
        throw ArgumentError.value(o.id, 'order.id', 'must be non‑empty');
      }
    }

    // Transactional upserts + deletes
    await db.transaction((txn) async {
      // 1) Upsert each incoming order
      for (var o in orders) {
        await _store.record(o.id).put(txn, o.toJson());
      }

      // 2) Delete any records not in the incoming list
      final existingKeys = await _store.findKeys(txn);
      final incomingKeys = orders.map((o) => o.id).toSet();
      final toDelete = existingKeys.where((k) => !incomingKeys.contains(k));
      if (toDelete.isNotEmpty) {
        await _store.records(toDelete.toList()).delete(txn);
      }
    });
  }
}
