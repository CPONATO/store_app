import 'package:flutter/material.dart';
import 'package:shop_app/views/screens/detail/screens/widgets/popular_product_widget.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/banner_widget.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/category_item_widget.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/header_widget.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/reuseable_text_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeaderWidget(),
            BannerWidget(),
            CategoryItemWidget(),
            ReuseableTextWidget(
              title: 'Popular Products',
              subTitle: 'View All',
            ),
            PopularProductWidget(),
          ],
        ),
      ),
    );
  }
}
