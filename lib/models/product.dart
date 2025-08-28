class Product {
  final int id;
  final String name;
  final String image;
  final int calories;
  final int cookTimeMinutes;
  final double rating;
  final int reviewCount;
  final bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.calories,
    required this.cookTimeMinutes,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isFavorite = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      calories: json['caloriesPerServing'] ?? 0,
      cookTimeMinutes: json['cookTimeMinutes'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'caloriesPerServing': calories,
      'cookTimeMinutes': cookTimeMinutes,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFavorite': isFavorite,
    };
  }
}
