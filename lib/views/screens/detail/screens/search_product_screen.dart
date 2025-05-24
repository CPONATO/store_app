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
      backgroundColor: Colors.white, // Thay đổi background thành màu trắng
      appBar: AppBar(
        backgroundColor: Colors.white, // AppBar cũng màu trắng
        elevation: 1, // Thêm shadow nhẹ
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true, // Tự động focus vào search field
          decoration: InputDecoration(
            labelText: "Search Products ...",
            labelStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none,
            hintText: "Search Products ...",
            hintStyle: TextStyle(color: Colors.grey[400]),
            suffixIcon: IconButton(
              onPressed: _searchProduct,
              icon: const Icon(Icons.search, color: Colors.blue),
            ),
          ),
          onSubmitted: (value) => _searchProduct(), // Search khi nhấn Enter
        ),
      ),
      body: Container(
        color: Colors.white, // Đảm bảo body cũng màu trắng
        child: Column(
          children: [
            // Divider line
            Container(height: 1, color: Colors.grey[200]),

            const SizedBox(height: 16),

            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_searchedProduct.isEmpty &&
                _searchController.text.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No Products Found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try searching with different keywords',
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else if (_searchedProduct.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Start Searching',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter product name to search',
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Results count
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          '${_searchedProduct.length} results found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),

                      // Products grid
                      Expanded(
                        child: GridView.builder(
                          itemCount: _searchedProduct.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: childAspectRatio,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                          itemBuilder: (context, index) {
                            final product = _searchedProduct[index];
                            return ProductItemWidget(product: product);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
