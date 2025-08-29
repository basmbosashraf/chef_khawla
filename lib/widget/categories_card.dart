import 'package:flutter/material.dart';

import '../views/category_details.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textCream = Color(0xFFF3E8D1);

    final items = <_CategoryItem>[
      _CategoryItem(label: 'Cake Flavors', image: 'assets/images/img_1.png'),
      _CategoryItem(label: 'Healthy Options', image: 'assets/images/img_2.png'),
      _CategoryItem(label: 'My Products', image: 'assets/images/whisk.png'),
      _CategoryItem(label: 'Merchandise Shop', image: 'assets/images/mug.png'),
      _CategoryItem(label: 'My Products', image: 'assets/images/spatula.png'),
      _CategoryItem(label: 'Occasion Packs', image: 'assets/images/gift.png'),
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
            child: Image.asset(imagePath),
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


