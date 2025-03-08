class FoodItem {
  final String image;
  final String name;
  final int price;
  final int quantity;

  FoodItem({
    required this.image,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory FoodItem.fromMap(Map<dynamic, dynamic> map) {
    return FoodItem(
      image: map['image'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}
