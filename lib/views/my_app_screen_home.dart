import 'package:chef_khawla/utils/constants.dart';
import 'package:chef_khawla/widget/banner.dart';
import 'package:chef_khawla/widget/my_icon_button.dart';
import 'package:chef_khawla/widget/product_card.dart';
import 'package:flutter/material.dart';
import 'package:chef_khawla/models/category.dart';
import 'package:chef_khawla/models/product.dart';
import 'package:chef_khawla/services/category_service.dart';
import 'package:chef_khawla/services/product_service.dart';
import 'package:chef_khawla/views/all_products_screen.dart';
import 'package:iconsax/iconsax.dart';
import '../widget/categories_card.dart';

class MyAppScreenHome extends StatefulWidget {
  const MyAppScreenHome({super.key});

  @override
  State<MyAppScreenHome> createState() => _MyAppScreenHomeState();
}

class _MyAppScreenHomeState extends State<MyAppScreenHome> {
  String selectedCategory = "All";
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

  Future<void> _loadCategories() async {
    try {
      final data = await CategoryService.getCategories();
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

  Future<void> _loadProducts() async {
    try {
      final data = await ProductService.getFeaturedProducts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/img_3.png"),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                /// الجزء العلوي (العنوان + النوتيفيكاشن)
                headerParts(),
                const SizedBox(height: 20),

                /// مربع البحث
                searchBar(),
                const SizedBox(height: 10),

                /// البانر
                const BannerToExplore(),
                const SizedBox(height: 20),

                /// عنوان الكاتيجوريز مع أيقونة
                Row(
                  children: [
                    const Icon(Iconsax.category, size: 22, color: Colors.black87),
                    const SizedBox(width: 8),
                    Text(
                      "Categories",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                const CategoriesSection()
                /// عرض الكاتيجوريز
                /* if (isLoadingCategories)
                const Center(child: CircularProgressIndicator())
              else if (errorMessage != null)
                Center(
                  child: Text(
                    'Error: $errorMessage',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (categories.isEmpty)
                  const Center(child: Text('No categories found'))
                else
                  GridView.builder(
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
                      final currentCategory = categories[index];
                      final isSelected = selectedCategory == currentCategory.name;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = currentCategory.name;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? kprimarycolor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 6,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : kprimarycolor.withOpacity(0.1),
                                child: Icon(
                                  Iconsax.category,
                                  size: 26,
                                  color: isSelected ? Colors.white : kprimarycolor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                currentCategory.name,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),*//* if (isLoadingCategories)
                const Center(child: CircularProgressIndicator())
              else if (errorMessage != null)
                Center(
                  child: Text(
                    'Error: $errorMessage',
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (categories.isEmpty)
                  const Center(child: Text('No categories found'))
                else
                  GridView.builder(
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
                      final currentCategory = categories[index];
                      final isSelected = selectedCategory == currentCategory.name;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCategory = currentCategory.name;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? kprimarycolor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 6,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : kprimarycolor.withOpacity(0.1),
                                child: Icon(
                                  Iconsax.category,
                                  size: 26,
                                  color: isSelected ? Colors.white : kprimarycolor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                currentCategory.name,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),*/

               , const SizedBox(height: 30),
              ],
            ),
          ),
        ),
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
