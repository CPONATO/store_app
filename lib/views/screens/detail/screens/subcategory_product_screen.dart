import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/controllers/product_controller.dart';
import 'package:shop_app/models/subcategory.dart';
import 'package:shop_app/provider/subcategory_product_provider.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/product_item_widget.dart';

class SubcategoryProductScreen extends ConsumerStatefulWidget {
  final Subcategory subcategory;

  const SubcategoryProductScreen({super.key, required this.subcategory});

  @override
  ConsumerState<SubcategoryProductScreen> createState() =>
      _SubcategoryProductScreenState();
}

class _SubcategoryProductScreenState
    extends ConsumerState<SubcategoryProductScreen> {
  @override
  void initState() {
    super.initState();
    final products = ref.read(subcategoryProductProvider);
    _fetchProduct();
  }

  Future<void> _fetchProduct() async {
    final ProductController productController = ProductController();
    try {
      final products = await productController.loadProductBySubcategory(
        widget.subcategory.subCategoryName,
      );
      ref.read(subcategoryProductProvider.notifier).setProduct(products);
    } catch (e) {
      print('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(subcategoryProductProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    final crossAxisCount = screenWidth < 600 ? 2 : 4;

    final childAspectRatio = screenWidth < 600 ? 2.8 / 4 : 4 / 5;

    return Scaffold(
      appBar: AppBar(title: Text(widget.subcategory.subCategoryName)),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductItemWidget(product: product);
          },
        ),
      ),
    );
  }
}
