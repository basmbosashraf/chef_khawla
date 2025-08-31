// import 'package:flutter/material.dart';
// import '../services/favorites_service.dart';
// import '../models/product.dart';
// import '../widget/product_card.dart';
// import '../utils/constants.dart';

// class FavoritesScreen extends StatefulWidget {
//   const FavoritesScreen({super.key});

//   @override
//   _FavoritesScreenState createState() => _FavoritesScreenState();
// }

// class _FavoritesScreenState extends State<FavoritesScreen> {
//   List<Product> favoriteProducts = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadFavorites();
//   }

//   Future<void> _loadFavorites() async {
//     try {
//       final favorites = await FavoritesService.getFavoriteProducts();
//       setState(() {
//         favoriteProducts = favorites;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _removeFromFavorites(Product product) async {
//     await FavoritesService.removeFromFavorites(product);
//     _loadFavorites();
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${product.name} removed from favorites'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kbackgroundcolor,
//       appBar: AppBar(
//         title: const Text(
//           'My Favorites',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: kprimarycolor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           if (favoriteProducts.isNotEmpty)
//             IconButton(
//               onPressed: () async {
//                 final confirm = await showDialog<bool>(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: const Text('Clear Favorites'),
//                     content: const Text('Are you sure you want to remove all favorites?'),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.of(context).pop(false),
//                         child: const Text('Cancel'),
//                       ),
//                       TextButton(
//                         onPressed: () => Navigator.of(context).pop(true),
//                         child: const Text('Clear All'),
//                       ),
//                     ],
//                   ),
//                 );
//                 if (confirm == true) {
//                   for (final product in favoriteProducts) {
//                     await FavoritesService.removeFromFavorites(product);
//                   }
//                   _loadFavorites();
//                 }
//               },
//               icon: const Icon(Icons.clear_all),
//             ),
//         ],
//       ),
//       body: isLoading
//           ? Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(kprimarycolor),
//               ),
//             )
//           : favoriteProducts.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.favorite_border,
//                         size: 80,
//                         color: Colors.grey[400],
//                       ),
//                       const SizedBox(height: 24),
//                       Text(
//                         'No favorites yet',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         'Start adding products to your favorites\nto see them here!',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[500],
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 )
//               : GridView.builder(
//                   padding: const EdgeInsets.all(16),
//                   itemCount: favoriteProducts.length,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     mainAxisSpacing: 16,
//                     crossAxisSpacing: 16,
//                     childAspectRatio: 0.75,
//                   ),
//                   itemBuilder: (context, index) {
//                     final product = favoriteProducts[index];
//                     return Stack(
//                       children: [
//                         ProductCard(product: product),
//                         Positioned(
//                           top: 8,
//                           right: 8,
//                           child: GestureDetector(
//                             onTap: () => _removeFromFavorites(product),
//                             child: Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 shape: BoxShape.circle,
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.1),
//                                     blurRadius: 4,
//                                   ),
//                                 ],
//                               ),
//                               child: const Icon(
//                                 Icons.favorite,
//                                 color: Colors.red,
//                                 size: 20,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//     );
//   }
// }
