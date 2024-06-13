class Product {
  final int id; // Add the id property
  final String name;
  final String category;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: int.parse(json['product_id']), // Parse 'product_id' as an integer
      name: json['name'],
      category: json['category'],
      price: double.parse(json['price']),
      imageUrl: json['image_url'],
    );
  }
}
