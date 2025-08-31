/*class Category {
  final String name;

  Category({required this.name});

  factory Category.fromJson(dynamic json) {
    // Handle both string format (new API) and object format (old API)
    if (json is String) {
      return Category(name: json);
    } else if (json is Map<String, dynamic>) {
      return Category(name: json['name'] ?? '');
    } else {
      return Category(name: json.toString());
    }
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
*/
class Category {
  final String id;
  final String name;
  final String imageUrl;
  final String? iconName;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.iconName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      iconName: json['icon'],
    );
  }
}
