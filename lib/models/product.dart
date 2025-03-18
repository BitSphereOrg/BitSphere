class Product {
  String name;
  String price;
  String desc;

  Product(this.name, this.price, this.desc);

  Map<String, String> toMap() => {"name": name, "price": price, "desc": desc};

  static bool isValid(String name, String price, String desc) {
    return name.isNotEmpty && price.isNotEmpty && desc.isNotEmpty;
  }
}