import 'package:flutter/material.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/popular_product_widget.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/banner_widget.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/category_item_widget.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/header_widget.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/reuseable_text_widget.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/top_rated_product_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.093,
        ),
        child: const HeaderWidget(),
      ),
      backgroundColor: Colors.grey[100], // Consistent background color
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom welcome section
              _buildWelcomeSection(),
              const BannerWidget(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: ReuseableTextWidget(
                  title: 'Categories',
                  subTitle: 'View All',
                ),
              ),
              const CategoryItemWidget(),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ReuseableTextWidget(
                  title: 'Popular Products',
                  subTitle: 'View All',
                ),
              ),
              const SizedBox(height: 8),
              const PopularProductWidget(),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ReuseableTextWidget(
                  title: 'Top Rated Products',
                  subTitle: 'View All',
                ),
              ),
              const TopRatedProductWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, Welcome',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Discover the perfect items for you',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
