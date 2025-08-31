import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_products';

  // Get all favorite products
  static Future<List<Product>> getFavoriteProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJson
          .map((json) => Product.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Add product to favorites
  static Future<bool> addToFavorites(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      // Check if product is already in favorites by ID
      final existingProduct = favoritesJson.any((json) {
        final productData = jsonDecode(json);
        return productData['id'] == product.id;
      });

      if (!existingProduct) {
        final productJson = jsonEncode(product.toJson());
        favoritesJson.add(productJson);
        await prefs.setStringList(_favoritesKey, favoritesJson);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Remove product from favorites
  static Future<bool> removeFromFavorites(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      // Remove by product ID
      favoritesJson.removeWhere((json) {
        final productData = jsonDecode(json);
        return productData['id'].toString() == product.id.toString();
      });

      await prefs.setStringList(_favoritesKey, favoritesJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if product is in favorites
  static Future<bool> isFavorite(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      // Check by product ID
      return favoritesJson.any((json) {
        final productData = jsonDecode(json);
        return productData['id'] == product.id;
      });
    } catch (e) {
      return false;
    }
  }

  // Toggle favorite status
  static Future<bool> toggleFavorite(Product product) async {
    final isFav = await isFavorite(product);
    if (isFav) {
      return await removeFromFavorites(product);
    } else {
      return await addToFavorites(product);
    }
  }
}
