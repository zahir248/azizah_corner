// cart_item.dart
class CartItem {
  final int cartId;
  final String name;
  final double price;
  int quantity; // Add quantity field

  CartItem({
    required this.cartId,
    required this.name,
    required this.price,
    this.quantity = 1, // Set default quantity to 1
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartId: json['cart_id'] is int ? json['cart_id'] : int.tryParse(json['cart_id'] ?? '0') ?? 0,
      name: json['name'] ?? '',
      price: double.parse(json['price'].toString()) ?? 0.0,
    );
  }
}
