import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shop_app/controllers/product_controller.dart';
import 'package:shop_app/controllers/subcategory_controller.dart';
import 'package:shop_app/models/category.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/models/subcategory.dart';
import 'package:shop_app/views/screens/detail/screens/widgets/inner_banner_widget.dart';
import 'package:shop_app/views/screens/detail/screens/widgets/inner_header_widget.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/product_item_widget.dart';
import 'package:shop_app/views/screens/detail/screens/widgets/subcategory_tile_widget.dart';

class InnerCategoryContentWidget extends StatefulWidget {
  final Category category;

  const InnerCategoryContentWidget({super.key, required this.category});
  @override
  State<InnerCategoryContentWidget> createState() =>
      _InnerCategoryContentWidgetState();
}

class _InnerCategoryContentWidgetState
    extends State<InnerCategoryContentWidget> {
  late Future<List<Subcategory>> _subCategories;
  late Future<List<Product>> futureProduct;
  final SubcategoryController _subcategoryController = SubcategoryController();

  @override
  void initState() {
    super.initState();
    _subCategories = _subcategoryController.getSubCategoryByCategoryName(
      widget.category.name,
    );
    futureProduct = ProductController().loadProductByCategory(
      widget.category.name,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: InnerHeaderWidget(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _subCategories = _subcategoryController
                .getSubCategoryByCategoryName(widget.category.name);
            futureProduct = ProductController().loadProductByCategory(
              widget.category.name,
            );
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InnerBannerWidget(image: widget.category.banner),
              _buildSectionHeader('Shop By Subcategories'),
              _buildSubcategoriesSection(),
              _buildSectionHeader('Popular Products'),
              _buildProductsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: Row(
              children: [
                Text(
                  'View All',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.blue[700],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoriesSection() {
    return FutureBuilder(
      future: _subCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return _buildErrorWidget('Could not load subcategories');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyStateWidget('No subcategories available');
        } else {
          final subcategories = snapshot.data!;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children:
                  subcategories.map((subcategory) {
                    return SubcategoryTileWidget(
                      image: subcategory.image,
                      title: subcategory.subCategoryName,
                    );
                  }).toList(),
            ),
          );
        }
      },
    );
  }

  Widget _buildProductsSection() {
    return FutureBuilder(
      future: futureProduct,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return _buildErrorWidget('Could not load products');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyStateWidget('No products available');
        } else {
          final products = snapshot.data!;
          return Container(
            height: 280,
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ProductItemWidget(product: product),
                );
              },
            ),
          );
        }
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _subCategories = _subcategoryController
                    .getSubCategoryByCategoryName(widget.category.name);
                futureProduct = ProductController().loadProductByCategory(
                  widget.category.name,
                );
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(CupertinoIcons.cube_box, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
