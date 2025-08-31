import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryService {
  // استبدل هذا بـ بياناتك المحلية مباشرة
  static Future<List<Category>> getCategories() async {
    // بيانات ثابتة محليًا بدلاً من تحميلها من API
    await Future.delayed(Duration(seconds: 2)); // محاكاة التأخير في تحميل البيانات

    List<Map<String, dynamic>> mockData = [
      {
        "id": "1", 
        "name": "Pizza", 
        "imageUrl": "https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg",
        "icon": "local_pizza"
      },
      {
        "id": "2", 
        "name": "Desserts", 
        "imageUrl": "https://images.pexels.com/photos/291528/pexels-photo-291528.jpeg",
        "icon": "cake"
      },
      {
        "id": "3", 
        "name": "Beverages", 
        "imageUrl": "https://images.pexels.com/photos/544961/pexels-photo-544961.jpeg",
        "icon": "local_drink"
      },
      {
        "id": "4", 
        "name": "Salads", 
        "imageUrl": "https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg",
        "icon": "eco"
      },
    ];

    // تحويل البيانات من Map إلى كائنات Category
    return mockData.map((categoryJson) => Category.fromJson(categoryJson)).toList();
  }

  static IconData getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'local_pizza':
        return Icons.local_pizza;
      case 'cake':
        return Icons.cake;
      case 'local_drink':
        return Icons.local_drink;
      case 'eco':
        return Icons.eco;
      default:
        return Icons.category;
    }
  }
}
