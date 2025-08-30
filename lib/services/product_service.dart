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
      Product(id: '1', name: 'Product 1', imageUrl: 'assets\images\img_1.png', price: 10.0, categoryId: '1'),
      Product(id: '2', name: 'Product 2', imageUrl: 'assets\images\img_1.png', price: 20.0, categoryId: '1'),
      Product(id: '3', name: 'Product 3', imageUrl: 'assets\images\img_1.png', price: 15.0, categoryId: '2'),
      Product(id: '4', name: 'Product 4', imageUrl: 'assets\images\img_1.png', price: 25.0, categoryId: '2'),
    ];

    // إرجاع المنتجات التي تطابق الـ categoryId
    return allProducts.where((product) => product.categoryId == categoryId).toList();
  }
  static Future<List<Product>> getFeaturedProducts() async {
    // استرجاع قائمة المنتجات المميزة من مصدر بيانات (API أو محلي)
    return [
      Product(id: '1', name: 'Product 1', imageUrl: 'assets\images\img_1.png', price: 10.0, categoryId: '1')

      // أضف المزيد من المنتجات هنا
    ];
  }
}
