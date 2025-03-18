import 'package:flutter/material.dart';
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

  void _addProduct(BuildContext scaffoldContext) {
    showDialog(
      context: scaffoldContext,
      builder: (dialogContext) {
        String name = "", price = "", desc = "";
        return AlertDialog(
          title: Text("Upload Product"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(onChanged: (val) => name = val, decoration: InputDecoration(labelText: "Name")),
              TextField(onChanged: (val) => price = val, decoration: InputDecoration(labelText: "Price")),
              TextField(onChanged: (val) => desc = val, decoration: InputDecoration(labelText: "Description")),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (!Product.isValid(name, price, desc)) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    SnackBar(content: Text("Fill all fields!")),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bitsphere")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(products[index].name),
            subtitle: Text(products[index].desc),
            trailing: Text(products[index].price),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addProduct(context),
        child: Icon(Icons.add),
        tooltip: "Upload Product",
      ),
    );
  }
}