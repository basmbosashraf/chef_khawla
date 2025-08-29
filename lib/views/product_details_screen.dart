import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productName;
  final String productImage;
  final double price;

  const ProductDetailScreen({
    super.key,
    required this.productName,
    required this.productImage,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// خلفية بالصورة + Overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/img_3.png"), // نفس الباكجراوند
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.2)),

          SafeArea(
            child: Column(
              children: [
                /// AppBar فخم شفاف
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Iconsax.arrow_left, size: 28, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Product Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.heart, size: 26, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                /// مكان للوجو
                Container(
                  height: 50,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      "LOGO",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// صورة المنتج
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    productImage,
                    height: 250,
                    width: 250,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 25),

                /// اسم المنتج + السعر
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "\$$price",
                        style: const TextStyle(
                          fontSize: 20,
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
        ],
      ),
    );
  }
}

