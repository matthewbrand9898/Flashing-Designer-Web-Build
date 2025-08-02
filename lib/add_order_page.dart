import 'package:flutter/material.dart';
import 'package:flashing_designer/models/order_model.dart';

class AddOrderPage extends StatefulWidget {
  const AddOrderPage({super.key});

  @override
  _AddOrderPageState createState() => _AddOrderPageState();
}

class _AddOrderPageState extends State {
  final _nameCtrl = TextEditingController();
  final _customerCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  static String? _optional(String? text) =>
      text == null || text.trim().isEmpty ? null : text.trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'NEW ORDER',
          style: TextStyle(
            fontFamily: 'Kanit',
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 24),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      _buildField(_nameCtrl, 'Order Name *', autofocus: true),
                      const SizedBox(height: 12),
                      _buildField(_customerCtrl, 'Customer Name'),
                      const SizedBox(height: 12),
                      _buildField(_addressCtrl, 'Address'),
                      const SizedBox(height: 12),
                      _buildField(
                        _phoneCtrl,
                        'Phone',
                        keyboard: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _emailCtrl,
                        'Email',
                        keyboard: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(null),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                            ),
                            onPressed: () {
                              final name = _nameCtrl.text.trim();
                              if (name.isEmpty) return;
                              Navigator.of(context).pop(Order(
                                name: name,
                                id: DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                                flashings: [],
                                customerName: _optional(_customerCtrl.text),
                                address: _optional(_addressCtrl.text),
                                phone: _optional(_phoneCtrl.text),
                                email: _optional(_emailCtrl.text),
                              ));
                            },
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label, {
    bool autofocus = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      autofocus: autofocus,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Kanit'),
        border: const OutlineInputBorder(),
      ),
      style: const TextStyle(fontFamily: 'Kanit'),
    );
  }
}
