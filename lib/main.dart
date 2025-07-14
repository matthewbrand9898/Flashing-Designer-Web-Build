import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;

import 'models/designer_model.dart';
import 'package:flutter/material.dart';

import 'order_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => DesignerModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if it's an installed PWA on web
    final isPwa =
        kIsWeb && web.window.matchMedia('(display-mode: standalone)').matches;
    // Check if it's running in a web iOS browser
    final isWebiOS = kIsWeb &&
        web.window.navigator.userAgent.contains(
          RegExp(r'iPad|iPod|iPhone'),
        );

    // The main MaterialApp
    final app = MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FLASHING DESIGNER',
      theme: ThemeData(
        cardTheme: const CardTheme(
          margin: EdgeInsets.zero,
          color: Colors.white,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        useMaterial3: true,
      ),
      home: const OrdersPage(),
    );

    // Wrap with a deep purple background and add bottom inset container
    return Container(
      color: Colors.deepPurple,
      child: Column(
        children: [
          Expanded(child: app),
          if (isPwa && isWebiOS)
            Container(
              height: 50,
              color: Colors.deepPurple,
            ),
        ],
      ),
    );
  }
}
