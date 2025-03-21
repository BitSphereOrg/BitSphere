import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [
    Product("Web App", "\$10", "A sleek frontend"),
    Product("API", "\$15", "RESTful backend"),
  ];

  void _addProduct() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        String name = "", price = "", desc = "";
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E2E2E), Color(0xFF1A1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 10)],
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Upload Product", style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),
                _buildTextField((val) => name = val, "Name"),
                SizedBox(height: 12),
                _buildTextField((val) => price = val, "Price"),
                SizedBox(height: 12),
                _buildTextField((val) => desc = val, "Description"),
                SizedBox(height: 20),
                AnimatedScaleButton(
                  onPressed: () {
                    if (!Product.isValid(name, price, desc)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Fill all fields!", style: GoogleFonts.montserrat()),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      products.add(Product(name, price, desc));
                    });
                    Navigator.pop(dialogContext);
                  },
                  child: Text("Add"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(void Function(String) onChanged, String label) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[800]!.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: GoogleFonts.montserrat(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Bitsphere"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E2E2E), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E2E2E), Color(0xFF1A1A1A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00C4B4), Color(0xFF00796B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text(
                  "Bitsphere",
                  style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              _buildDrawerItem(Icons.home, "Home", () => Navigator.pop(context)),
              _buildDrawerItem(Icons.person, "Profile", () {
                Navigator.pop(context);
                // Add navigation later
              }),
              _buildDrawerItem(Icons.settings, "Settings", () {
                Navigator.pop(context);
                // Add navigation later
              }),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A1A), Color(0xFF2E2E2E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Product list
          ListView.builder(
            padding: EdgeInsets.fromLTRB(16, kToolbarHeight + 16, 16, 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Card(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF424242), Color(0xFF212121)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(products[index].name, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                      subtitle: Text(products[index].desc, style: GoogleFonts.montserrat(color: Colors.white70)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(products[index].price, style: GoogleFonts.montserrat(color: Color(0xFF00C4B4), fontSize: 16)),
                          SizedBox(width: 12),
                          AnimatedScaleButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Bought ${products[index].name}", style: GoogleFonts.montserrat()),
                                  backgroundColor: Color(0xFF00796B),
                                ),
                              );
                            },
                            child: Text("Buy"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: AnimatedScaleButton(
        onPressed: _addProduct,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: GoogleFonts.montserrat(color: Colors.white)),
      onTap: onTap,
      hoverColor: Colors.teal.withOpacity(0.2),
    );
  }
}

// Custom animated button widget
class AnimatedScaleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  AnimatedScaleButton({required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(1.0),
        child: ElevatedButton(
          onPressed: onPressed,
          child: child,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFA726),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}