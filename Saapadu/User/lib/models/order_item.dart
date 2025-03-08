// lib/models/order_item.dart
class OrderItem {
  final String name;
  final double price;
  final int quantity;
  final bool isPurchased;

  OrderItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.isPurchased,
  });
}
