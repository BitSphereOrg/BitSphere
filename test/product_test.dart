import 'package:flutter_test/flutter_test.dart';
import 'package:bitsphere/models/product.dart';

void main() {
  test('Adding a valid product returns correct map', () {
    final product = Product("Test Code", "\$5", "Test desc");
    expect(product.toMap(), {"name": "Test Code", "price": "\$5", "desc": "Test desc"});
  });

  test('Empty fields are invalid', () {
    expect(Product.isValid("", "\$5", "Test"), false);
    expect(Product.isValid("Test", "", "Test"), false);
    expect(Product.isValid("Test", "\$5", ""), false);
    expect(Product.isValid("Test", "\$5", "Test"), true);
  });
}