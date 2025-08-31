import 'package:flutter/material.dart';
import 'package:chef_khawla/models/category.dart';
import 'package:chef_khawla/models/product.dart';
import 'package:chef_khawla/services/category_service.dart';
import 'package:chef_khawla/services/product_service.dart';
import 'package:chef_khawla/views/all_products_screen.dart';
import 'package:chef_khawla/views/checkout_screen.dart';
import 'package:iconsax/iconsax.dart';
import 'package:chef_khawla/widget/categories_card.dart';
import 'package:chef_khawla/widget/product_card.dart';
import 'package:chef_khawla/widget/my_icon_button.dart'; 
import 'package:chef_khawla/widget/banner.dart';
import 'package:chef_khawla/utils/constants.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

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
          categoryName: category.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2E3192),
                  Color(0xFF1BFFFF),
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage("assets/images/img_3.png"),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildHeader(cartProvider),
                        const SizedBox(height: 24),
                        _buildSearchBar(),
                        const SizedBox(height: 20),
                        const BannerToExplore(),
                        const SizedBox(height: 32),
                        _buildCategoriesSection(),
                        const SizedBox(height: 32),
                        _buildFeaturedProductsSection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(CartProvider cartProvider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What are you",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              const Text(
                "cooking today?",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Stack(
              children: [
                MyIconButton(
                  icon: Iconsax.shopping_cart,
                  pressed: () {
                    // Navigate to checkout screen
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CheckoutScreen(),
                      ),
                    );
                  },
                ),
                if (cartProvider.totalQuantity > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Text(
                        '${cartProvider.totalQuantity}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            MyIconButton(icon: Iconsax.notification, pressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          filled: true,
          prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
          fillColor: Colors.white,
          border: InputBorder.none,
          hintText: "Search any recipes",
          hintStyle: const TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: kprimarycolor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.category, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              "Categories",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        isLoadingCategories
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : errorMessage != null
                ? Center(
                    child: Text(
                      'Error: $errorMessage',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : categories.isEmpty
                    ? const Center(
                        child: Text(
                          'No categories found',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return GestureDetector(
                            onTap: () => navigateToCategoryProducts(category),
                            child: CategoryCard(category: category),
                          );
                        },
                      ),
      ],
    );
  }

  Widget _buildFeaturedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.star, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              "Featured Products",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        isLoadingProducts
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : errorMessage != null
                ? Center(
                    child: Text(
                      'Error: $errorMessage',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : products.isEmpty
                    ? const Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(product: product);
                        },
                      ),
      ],
    );
  }
}
