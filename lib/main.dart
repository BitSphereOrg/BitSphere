import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/product_list_screen.dart';

void main() {
  runApp(BitsphereApp());
}

class BitsphereApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bitsphere',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF00C4B4), // Teal
        scaffoldBackgroundColor: Color(0xFF1A1A1A), // Charcoal
        textTheme: GoogleFonts.montserratTextTheme(
          ThemeData.dark().textTheme.copyWith(
            headlineSmall: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFA726), // Orange
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 8,
        ),
      ),
      home: ProductListScreen(),
    );
  }
}