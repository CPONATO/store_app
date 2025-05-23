import 'package:flutter/material.dart';
import 'package:shop_app/controllers/product_controller.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/product_item_widget.dart';

class SearchProductScreen extends StatefulWidget {
  const SearchProductScreen({super.key});

  @override
  State<SearchProductScreen> createState() => _SearchProductScreenState();
}

class _SearchProductScreenState extends State<SearchProductScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductController _productController = ProductController();
  List<Product> _searchedProduct = [];
  bool _isLoading = false;

  void _searchProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        final products = await _productController.searchProduct(query);
        setState(() {
          _searchedProduct = products;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final crossAxisCount = screenWidth < 600 ? 2 : 4;

    final childAspectRatio = screenWidth < 600 ? 2.8 / 4 : 4 / 5;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: "Search Products ...",
            suffixIcon: IconButton(
              onPressed: _searchProduct,
              icon: const Icon(Icons.search),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          if (_isLoading)
            Center(child: const CircularProgressIndicator())
          else if (_searchedProduct.isEmpty)
            const Center(child: Text('No Product Found'))
          else
            Expanded(
              child: GridView.builder(
                itemCount: _searchedProduct.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final product = _searchedProduct[index];
                  return ProductItemWidget(product: product);
                },
              ),
            ),
        ],
      ),
    );
  }
}
