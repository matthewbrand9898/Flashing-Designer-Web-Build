import 'package:flashing_designer/order_page.dart';
import 'package:provider/provider.dart';

import 'models/designer_model.dart';
import 'package:flutter/material.dart';

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
    return MaterialApp(
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
  }
}
