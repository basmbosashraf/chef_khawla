import 'package:chef_khawla/utils/constants.dart';
import 'package:chef_khawla/views/my_app_screen_home.dart';
import 'package:chef_khawla/views/favorites_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:chef_khawla/views/settings_screen.dart';
import 'package:chef_khawla/views/checkout_screen.dart';
import 'package:chef_khawla/models/category.dart';
import '../models/product.dart';

class AppMainScreen extends StatefulWidget {
  const AppMainScreen({super.key});
  @override
  State<AppMainScreen> createState() => _AppMainScreenState();
}
class _AppMainScreenState extends State<AppMainScreen> {
  int selectedIndex = 0;
  late final PageController _pageController;
  late final List<Widget> pages;
  
  // تعريف قائمة favoriteProducts
  List<Product> yourFavoriteProductsList = [];  // تأكد من أنها من نوع Product

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);

    // تحديث الصفحة لتشمل قائمة المنتجات المفضلة
    pages = [
       MyAppScreenHome(),
      FavoritesScreen(favoriteProducts: yourFavoriteProductsList),  // تمرير قائمة المفضلة
      navBarPage(Iconsax.calendar5),
      const SettingsScreen(),
      const CheckoutScreen(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: selectedIndex,
        iconSize: 28,
        selectedItemColor: kprimarycolor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          color: kprimarycolor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 0 ? Iconsax.home5 : Iconsax.home_1),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(selectedIndex == 1 ? Iconsax.heart5 : Iconsax.heart),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 2 ? Iconsax.calendar5 : Iconsax.calendar,
            ),
            label: "Meal Plan",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 3 ? Iconsax.setting_21 : Iconsax.setting_2,
            ),
            label: "Settings",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 4 ? Iconsax.setting_21 : Iconsax.shopping_cart,
            ),
            label: "Check-out",
          ),
        ],
      ),
    );
  }

  navBarPage(iconName) {
    return Center(child: Icon(iconName, size: 100, color: kprimarycolor));
  }
}
