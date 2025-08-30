import 'package:flutter/material.dart';
import 'package:chef_khawla/models/category.dart';
import 'package:chef_khawla/models/product.dart';
import 'package:chef_khawla/services/category_service.dart';
import 'package:chef_khawla/services/product_service.dart';
import 'package:chef_khawla/views/all_products_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:chef_khawla/widget/categories_card.dart';
import 'package:chef_khawla/widget/product_card.dart';
import 'package:chef_khawla/widget/my_icon_button.dart'; 
import 'package:chef_khawla/widget/banner.dart';

class MyAppScreenHome extends StatefulWidget {
  const MyAppScreenHome({super.key});

  @override
  State<MyAppScreenHome> createState() => _MyAppScreenHomeState();
}

class _MyAppScreenHomeState extends State<MyAppScreenHome> {
  List<Category> categories = [];
  List<Product> products = [];
  bool isLoadingCategories = true;
  bool isLoadingProducts = true;
  String? errorMessage;
  bool isFavorite = false; // تغيير هذه القيمة حسب الحاجة

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  // تحميل الكاتيجوريز من خدمة الفئة
  Future<void> _loadCategories() async {
    try {
      final data = await CategoryService.getCategories(); // استخدم البيانات الخاصة بك هنا
      setState(() {
        categories = data;
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoadingCategories = false;
      });
    }
  }

  // تحميل المنتجات من خدمة المنتجات
  Future<void> _loadProducts() async {
    try {
      final data = await ProductService.getFeaturedProducts(); // استخدم المنتجات الخاصة بك هنا
      setState(() {
        products = data;
        isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoadingProducts = false;
      });
    }
  }

  // الانتقال إلى صفحة تفاصيل المنتجات عند الضغط على كاتيجوري
  void navigateToCategoryProducts(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllProductsScreen(
          categoryId: category.id,
          isFavorite: isFavorite, // تمرير isFavorite عند الانتقال
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Chef Khawla'),
        backgroundColor: Colors.green,
      ),*/
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/img_3.png"),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
        child:Container(
          color: Colors.black.withOpacity(0.5),
          child:  SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  headerParts(),
                  const SizedBox(height: 20),

                  /// مربع البحث
                  searchBar(),
                  const SizedBox(height: 10),

                  /// البانر
                   BannerToExplore(),
                  const SizedBox(height: 20),

                  // عرض عنوان الصفحة
                  Row(
                    children: [
                      const Icon(Iconsax.category, size: 22, color: Colors.black87),
                      const SizedBox(width: 8),
                      Text(
                        "Categories",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                                          color:Colors.white

                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                   isLoadingCategories
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                          ? Center(
                              child: Text(
                                'Error: $errorMessage',
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : categories.isEmpty
                              ? const Center(child: Text('No categories found'))
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  itemCount: categories.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 15,
                                    crossAxisSpacing: 15,
                                    childAspectRatio: 1.1,
                                  ),
                                  itemBuilder: (context, index) {
                                    final category = categories[index];
                                    return GestureDetector(
                                      onTap: () => navigateToCategoryProducts(category),
                                      child: CategoryCard(category: category),
                                    );
                                  },
                                ),


                  // عرض الأطباق المميزة (Featured Products)
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Icon(Iconsax.box, size: 22, color: Colors.black87),
                      const SizedBox(width: 8),
                      Text(
                        "Featured Products",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  isLoadingProducts
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage != null
                          ? Center(
                              child: Text(
                                'Error: $errorMessage',
                                style: const TextStyle(color: Colors.red),
                              ),
                            )
                          : products.isEmpty
                              ? const Center(child: Text('No products found'))
                              : GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  itemCount: products.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 15,
                                    crossAxisSpacing: 15,
                                    childAspectRatio: 1.1,
                                  ),
                                  itemBuilder: (context, index) {
                                    final product = products[index];
                                    return ProductCard(
                                      product: product,
                                      isFavorite: isFavorite,
                                      onFavoriteTap: () {
                                        setState(() {
                                          product.isFavorite = !product.isFavorite; // تغيير حالة الـ isFavorite عند النقر
                                        });
                                      },
                                    );
                                  },
                                ),
                ],
              ),
            ),
          ),
        ),
        )
       
      ),
    );
  }

  Widget headerParts() {
    return Row(
      children: [
        Text(
          "What are you\ncooking today?",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1,
            color: Colors.white
          ),
        ),
        Spacer(),
        MyIconButton(icon: Iconsax.notification, pressed: () {}),
      ],
    );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          prefixIcon: Icon(Iconsax.search_normal),
          fillColor: Colors.white,
          border: InputBorder.none,
          hintText: "Search any recipes",
          hintStyle: TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
