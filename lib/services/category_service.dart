import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';

import '../models/category.dart';

class CategoryService {
  // استبدل هذا بـ بياناتك المحلية مباشرة
  static Future<List<Category>> getCategories() async {
    // بيانات ثابتة محليًا بدلاً من تحميلها من API
    await Future.delayed(Duration(seconds: 2)); // محاكاة التأخير في تحميل البيانات

    List<Map<String, dynamic>> mockData = [
      {"id": "1", "name": "Pizza", "imageUrl": "url_to_image_1"},
      {"id": "2", "name": "Cake", "imageUrl": "url_to_image_2"},
      {"id": "3", "name": "Beverages", "imageUrl": "url_to_image_3"},
    ];

    // تحويل البيانات من Map إلى كائنات Category
    return mockData.map((categoryJson) => Category.fromJson(categoryJson)).toList();
  }
}
