import 'package:flutter/material.dart';
import 'package:shop_app/controllers/product_controller.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/product_item_widget.dart';

class PopularProductWidget extends StatefulWidget {
  const PopularProductWidget({super.key});

  @override
  State<PopularProductWidget> createState() => _PopularProductWidgetState();
}

class _PopularProductWidgetState extends State<PopularProductWidget> {
  late Future<List<Product>> futurePopularProduct;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futurePopularProduct = ProductController().loadPopularProduct();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: futurePopularProduct,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No Popular Products'));
        } else {
          final products = snapshot.data;
          return SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: products!.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductItemWidget(product: product);
              },
            ),
          );
        }
      },
    );
  }
}
