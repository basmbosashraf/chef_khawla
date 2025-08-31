import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
/*
class ProductService {
  static const String baseUrl = 'https://dummyjson.com/recipes';

  static Future<List<Product>> getFeaturedProducts() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl?limit=10&skip=0&select=name,image,caloriesPerServing,cookTimeMinutes,rating,reviewCount',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> recipes = jsonData['recipes'] ?? [];
        return recipes.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load featured products: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load featured products: $e');
    }
  }

  static Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl?select=name,image,caloriesPerServing,cookTimeMinutes,rating,reviewCount',
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final List<dynamic> recipes = jsonData['recipes'] ?? [];
        return recipes.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load all products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load all products: $e');
    }
  }
}
*/class ProductService {
  // دالة لتحميل المنتجات بناءً على الـ categoryId
  static Future<List<Product>> getProductsByCategory(String categoryId) async {
    // هنا يمكنك إضافة منطق لتحميل البيانات
    // مثلًا، يمكننا استخدام بيانات ثابتة كأنها من API
    await Future.delayed(const Duration(seconds: 1)); // محاكاة تأخير لتحميل البيانات من الـ API

    List<Product> allProducts = [
      Product(id: '1', name: 'Margherita Pizza', imageUrl: 'https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg', price: 12.99, categoryId: '1'),
      Product(id: '2', name: 'Pepperoni Pizza', imageUrl: 'https://images.pexels.com/photos/708587/pexels-photo-708587.jpeg', price: 15.99, categoryId: '1'),
      Product(id: '3', name: 'Chocolate Cake', imageUrl: 'https://images.pexels.com/photos/291528/pexels-photo-291528.jpeg', price: 8.99, categoryId: '2'),
      Product(id: '4', name: 'Cheesecake', imageUrl: 'https://images.pexels.com/photos/140831/pexels-photo-140831.jpeg', price: 9.99, categoryId: '2'),
      Product(id: '5', name: 'Fresh Orange Juice', imageUrl: 'https://images.pexels.com/photos/544961/pexels-photo-544961.jpeg', price: 4.99, categoryId: '3'),
      Product(id: '6', name: 'Iced Coffee', imageUrl: 'https://images.pexels.com/photos/302899/pexels-photo-302899.jpeg', price: 3.99, categoryId: '3'),
      Product(id: '7', name: 'Caesar Salad', imageUrl: 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg', price: 7.99, categoryId: '4'),
      Product(id: '8', name: 'Greek Salad', imageUrl: 'https://images.pexels.com/photos/1059905/pexels-photo-1059905.jpeg', price: 8.99, categoryId: '4'),
    ];

    // إرجاع المنتجات التي تطابق الـ categoryId
    return allProducts.where((product) => product.categoryId == categoryId).toList();
  }

  static Future<List<Product>> getFeaturedProducts() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Product(id: '1', name: 'Margherita Pizza', imageUrl: 'https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg', price: 12.99, categoryId: '1'),
      Product(id: '3', name: 'Chocolate Cake', imageUrl: 'https://images.pexels.com/photos/291528/pexels-photo-291528.jpeg', price: 8.99, categoryId: '2'),
      Product(id: '5', name: 'Fresh Orange Juice', imageUrl: 'https://images.pexels.com/photos/544961/pexels-photo-544961.jpeg', price: 4.99, categoryId: '3'),
      Product(id: '7', name: 'Caesar Salad', imageUrl: 'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg', price: 7.99, categoryId: '4'),
    ];
  }
}
