import 'package:chef_khawla/views/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryName;

  const CategoryDetailScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    // هنا بنعمل لستة Static Products
    List<Map<String, String>> staticProducts = List.generate(
      16,
          (index) => {
        "name": "Product ${index + 1}",
        "image": "https://via.placeholder.com/150", // صورة ثابتة Placeholder
        "price": "\$33" // سعر ثابت
      },
    );

    // فلترة المنتجات حسب السيرش
    List<Map<String, String>> filteredProducts = staticProducts
        .where((p) => p["name"]!
        .toLowerCase()
        .contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          /// الخلفية بالصورة + Layer
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/img_3.png"), // خلفية فخمة
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.2), // عشان المحتوى يوضح
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// AppBar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.arrow_left, size: 28, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.categoryName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                /// Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search in ${widget.categoryName}",
                      prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// GridView للمنتجات
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GridView.builder(
                      itemCount: filteredProducts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 15,
                        crossAxisSpacing: 15,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>

                                    ProductDetailScreen(
                                  productName: "Product ${index + 1}",
                                  productImage: "https://via.img_1.com/300", // نفس الصورة المؤقتة
                                  price: 33.0,
                                    ),
                              ),
                            );
                          },

                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// صورة المنتج
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      product["image"]!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product["name"]!,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        product["price"]!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
