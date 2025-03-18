import 'package:flutter/material.dart';
import 'screens/product_list_screen.dart';

void main() {
  runApp(BitsphereApp());
}

class BitsphereApp extends StatelessWidget {
  const BitsphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitsphere',
      home: ProductListScreen(),
    );
  }
}