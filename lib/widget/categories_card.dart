import 'package:flutter/material.dart';

import '../views/category_details.dart';
import '../services/category_service.dart';




import 'package:chef_khawla/models/category.dart'; 
/*
class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textCream = Color(0xFFF3E8D1);

    final items = <_CategoryItem>[
      _CategoryItem(label: 'Cake Flavors', image: 'assets/images/img_1.png'),
      _CategoryItem(label: 'Healthy Options', image: 'assets/images/img_1.png'),
      _CategoryItem(label: 'My Products', image: 'assets/images/img_1.png'),
      _CategoryItem(label: 'Merchandise Shop', image: 'assets/images/img_1.png'),
      _CategoryItem(label: 'My Products', image: 'assets/images/img_1.png'),
      _CategoryItem(label: 'Occasion Packs', image: 'assets/images/img_1.png'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return _CategoryCard(
          label: item.label,
          imagePath: item.image,
          textColor: textCream,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryDetailScreen(
                  categoryName: item.label,
                ),
              ),
            );
          },

        );
      },
    );
  }
}

class _CategoryItem {
  final String label;
  final String image;
  const _CategoryItem({required this.label, required this.image});
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final String imagePath;
  final Color textColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    required this.imagePath,
    required this.textColor,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double circleSize = MediaQuery.of(context).size.width < 380 ? 110 : 140;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: Image.asset(imagePath,
              height: 60,
              width: 60
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


*/




class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final iconSize = screenWidth * 0.08;
    final imageSize = screenWidth * 0.10; 

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category Icon
            Container(
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                CategoryService.getCategoryIcon(category.iconName ?? ''),
                size: iconSize,
                color: Colors.orange[700],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            
            // Category Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                category.imageUrl,
                height: imageSize,
                width: imageSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: imageSize,
                    width: imageSize,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      CategoryService.getCategoryIcon(category.iconName ?? ''),
                      color: Colors.grey[600],
                      size: iconSize,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            
            // Category Name
            Text(
              category.name,
              style: TextStyle(
                fontSize: screenWidth * 0.035, 
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
