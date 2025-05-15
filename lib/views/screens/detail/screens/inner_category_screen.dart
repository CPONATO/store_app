import 'package:flutter/material.dart';
import 'package:shop_app/models/category.dart';
import 'package:shop_app/views/screens/detail/screens/widgets/inner_category_content_widget.dart';
import 'package:shop_app/views/screens/nav_screens/account_screen.dart';
import 'package:shop_app/views/screens/nav_screens/cart_screen.dart';
import 'package:shop_app/views/screens/nav_screens/category_screen.dart';
import 'package:shop_app/views/screens/nav_screens/favorite_screen.dart';
import 'package:shop_app/views/screens/nav_screens/store_screen.dart';

class InnerCategoryScreen extends StatefulWidget {
  final Category category;

  const InnerCategoryScreen({super.key, required this.category});
  @override
  State<InnerCategoryScreen> createState() => _InnerCategoryScreenState();
}

class _InnerCategoryScreenState extends State<InnerCategoryScreen> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      InnerCategoryContentWidget(category: widget.category),
      FavoriteScreen(),
      CategoryScreen(),
      StoreScreen(),
      CartScreen(),
      AccountScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: pages[pageIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.transparent,
        currentIndex: pageIndex,
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: pageIndex == 0 ? Colors.blue[50] : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                "assets/icons/home.png",
                width: 22,
                height: 22,
                color: pageIndex == 0 ? Colors.blue[700] : Colors.grey[600],
              ),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: pageIndex == 1 ? Colors.blue[50] : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                "assets/icons/love.png",
                width: 22,
                height: 22,
                color: pageIndex == 1 ? Colors.blue[700] : Colors.grey[600],
              ),
            ),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: pageIndex == 2 ? Colors.blue[50] : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.category_outlined,
                size: 22,
                color: pageIndex == 2 ? Colors.blue[700] : Colors.grey[600],
              ),
            ),
            label: "Category",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: pageIndex == 3 ? Colors.blue[50] : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                "assets/icons/mart.png",
                width: 22,
                height: 22,
                color: pageIndex == 3 ? Colors.blue[700] : Colors.grey[600],
              ),
            ),
            label: "Stores",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: pageIndex == 4 ? Colors.blue[50] : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  Image.asset(
                    "assets/icons/cart.png",
                    width: 22,
                    height: 22,
                    color: pageIndex == 4 ? Colors.blue[700] : Colors.grey[600],
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red[500],
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: pageIndex == 5 ? Colors.blue[50] : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                "assets/icons/user.png",
                width: 22,
                height: 22,
                color: pageIndex == 5 ? Colors.blue[700] : Colors.grey[600],
              ),
            ),
            label: "Account",
          ),
        ],
      ),
    );
  }
}
