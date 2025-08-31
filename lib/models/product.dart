class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String categoryId;
  bool isFavorite;  

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.categoryId,
    this.isFavorite = false, 
  });

  // دالة من JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      price: json['price'].toDouble(),
      categoryId: json['categoryId'],
    );
  }

  // دالة لتحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'categoryId': categoryId,
    };
  }
}
