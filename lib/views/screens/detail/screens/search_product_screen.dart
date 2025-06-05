import 'dart:async';
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
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi trong text field
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Hàm được gọi mỗi khi text thay đổi
  void _onSearchChanged() {
    // Hủy timer cũ nếu có
    _debounceTimer?.cancel();

    // Tạo timer mới với delay 500ms
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        _searchProduct(query);
      } else {
        // Nếu query rỗng, xóa kết quả search
        setState(() {
          _searchedProduct = [];
          _isLoading = false;
        });
      }
    });
  }

  void _searchProduct(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final products = await _productController.searchProduct(query);
      if (mounted) {
        setState(() {
          _searchedProduct = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 4;
    final childAspectRatio = screenWidth < 600 ? 2.8 / 4 : 4 / 5;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Search Products ...",
            labelStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none,
            hintText: "Search Products ...",
            hintStyle: TextStyle(color: Colors.grey[400]),
            suffixIcon:
                _searchController.text.isNotEmpty
                    ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchedProduct = [];
                        });
                      },
                      icon: const Icon(Icons.clear, color: Colors.grey),
                    )
                    : const Icon(Icons.search, color: Colors.blue),
          ),
          onChanged: (value) {
            // Trigger rebuild để hiển thị/ẩn clear button
            setState(() {});
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Divider line
            Container(height: 1, color: Colors.grey[200]),
            const SizedBox(height: 16),

            // Loading indicator
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Searching...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            // No results found
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
                      const SizedBox(height: 16),
                      Text(
                        'Search query: "${_searchController.text}"',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // Empty state (no search yet)
            else if (_searchedProduct.isEmpty && _searchController.text.isEmpty)
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
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.blue[700],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Search results appear as you type',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // Search results
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Results count with search query
                      Container(
                        padding: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_searchedProduct.length} results found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    'for "${_searchController.text}"',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

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
