import 'package:flutter/material.dart';
import 'package:flashing_designer/models/order_model.dart';
import 'package:flashing_designer/order_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flashing_designer/models/designer_model.dart';

import 'add_order_page.dart';
import 'edit_order_page.dart';
import 'flashing_thumbnail_list.dart';

String capitalizeWords(String input) {
  if (input.isEmpty) return input;
  return input.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  OrdersPageState createState() => OrdersPageState();
}

class OrdersPageState extends State<OrdersPage> {
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await OrderStorage.readOrders();
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  Future<void> addOrder(Order newOrder) async {
    // 1) Persist it
    await OrderStorage.saveOrder(newOrder);

    // 2) Update local list & UI
    setState(() {
      _orders.add(newOrder);
    });
  }

  Future<void> deleteOrder(String id) async {
    // 1) Remove from IndexedDB
    await OrderStorage.deleteOrder(id);

    // 2) Update local list & UI
    setState(() {
      _orders.removeWhere((o) => o.id == id);
    });
  }

  Future<void> _showAddOrderDialog() async {
    final newOrder = await Navigator.of(context).push<Order>(
      MaterialPageRoute(builder: (_) => const AddOrderPage()),
    );
    if (newOrder != null) {
      await addOrder(newOrder);
      setState(() {});
    }
  }

  Future<void> _showEditOrderDialog(int index) async {
    final existing = _orders[index];

    // 1️⃣ Push the full-screen EditOrderPage, passing in the existing order
    final updated = await Navigator.of(context).push<Order?>(
      MaterialPageRoute(
        builder: (_) => EditOrderPage(order: existing),
      ),
    );

    // 2️⃣ If the user tapped “Save”, updated != null.  Update list + storage + UI
    if (updated != null) {
      setState(() {
        _orders[index] = updated;
      });
      await OrderStorage.saveOrder(updated);
    }
  }

  Future<void> _deleteOrder(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Center(
          child: Text('DELETE ORDER',
              style: TextStyle(
                  fontFamily: 'Kanit', color: Colors.deepPurple, fontSize: 18)),
        ),
        content: Text(
          'Are you sure you want to delete "${_orders[index].name}"?',
          style: const TextStyle(fontFamily: 'Kanit'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Kanit')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete',
                style: TextStyle(fontFamily: 'Kanit', color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (ok == true) {
      await deleteOrder(_orders[index].id);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat.yMMMd().add_jm();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text('ORDERS',
            style: TextStyle(
                fontFamily: 'Kanit', color: Colors.white, fontSize: 22)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(
                  child: Text('No orders yet',
                      style: TextStyle(fontFamily: 'Kanit', fontSize: 18)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemCount: _orders.length,
                  itemBuilder: (_, i) {
                    final realIndex = _orders.length - 1 - i;
                    final o = _orders[realIndex];
                    final created =
                        DateTime.fromMillisecondsSinceEpoch(int.parse(o.id))
                            .toLocal();
                    final createdStr = dateFmt.format(created);
                    final flashCount = o.flashings.length;
                    final flashText = flashCount == 0
                        ? 'No Flashings'
                        : '$flashCount ${flashCount == 1 ? 'Flashing' : 'Flashings'}';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          final model = context.read<DesignerModel>();
                          model.setFlashings(
                            o.flashings,
                            orderIndex: realIndex,
                            orderName: o.name,
                            orderDate: created,
                            customerName: o.customerName,
                            customerAddress: o.address,
                            customerPhone: o.phone,
                            customerEmail: o.email,
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FlashingGridPage()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(o.name.toUpperCase(),
                                  style: const TextStyle(
                                      fontFamily: 'Kanit',
                                      fontSize: 18,
                                      color: Colors.deepPurple)),
                              const SizedBox(height: 6),
                              if (o.customerName != null)
                                Text(
                                    'Customer:  ${capitalizeWords(o.customerName ?? '')}',
                                    style: const TextStyle(
                                        fontFamily: 'Kanit',
                                        color: Colors.black54)),
                              if (o.address != null)
                                Text(
                                    'Address:     ${capitalizeWords(o.address ?? '')}',
                                    style: const TextStyle(
                                        fontFamily: 'Kanit',
                                        color: Colors.black54)),
                              if (o.email != null)
                                Text(
                                    'Email:          ${capitalizeWords(o.email ?? '')}',
                                    style: const TextStyle(
                                        fontFamily: 'Kanit',
                                        color: Colors.black54)),
                              if (o.phone != null)
                                Text('Phone:        ${o.phone}',
                                    style: const TextStyle(
                                        fontFamily: 'Kanit',
                                        color: Colors.black54)),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Created:     $createdStr',
                                      style: const TextStyle(
                                          fontFamily: 'Kanit',
                                          color: Colors.black54)),
                                  Text(flashText,
                                      style: const TextStyle(
                                          fontFamily: 'Kanit',
                                          color: Colors.black54)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      FontAwesomeIcons.solidPenToSquare,
                                      color: Colors.deepPurple,
                                      size: 22,
                                    ),
                                    tooltip: 'EDIT ORDER',
                                    onPressed: () =>
                                        _showEditOrderDialog(realIndex),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    tooltip: 'DELETE ORDER',
                                    onPressed: () => _deleteOrder(realIndex),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOrderDialog,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
