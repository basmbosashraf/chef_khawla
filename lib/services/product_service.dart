import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

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
