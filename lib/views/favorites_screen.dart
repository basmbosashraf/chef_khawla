import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/favorites_service.dart';
import '../utils/constants.dart';
import '../widget/product_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with AutomaticKeepAliveClientMixin {
  List<Product> favoriteProducts = [];
  bool isLoading = true;

  @override
  bool get wantKeepAlive => false; // Don't keep alive to ensure fresh data

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh favorites when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadFavorites();
      }
    });
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await FavoritesService.getFavoriteProducts();
      // Favorites loaded; keep UI silent in production
      if (mounted) {
        setState(() {
          favoriteProducts = favorites;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(Product product) async {
    final success = await FavoritesService.toggleFavorite(product);
    if (success) {
      await _loadFavorites(); // always reload from SharedPreferences
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: kbackgroundcolor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'Favorites',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : favoriteProducts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No favorites yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the heart icon to add recipes to favorites',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(15),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.9,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: favoriteProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(
                          key: ValueKey(
                            'favorite_${favoriteProducts[index].id}',
                          ), // Unique key for favorites
                          product: favoriteProducts[index],
                          isGridLayout: true,
                          onTap: () {
                            // TODO: Navigate to recipe details
                          },
                          onFavoriteTap: () {
                            _toggleFavorite(favoriteProducts[index]);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
