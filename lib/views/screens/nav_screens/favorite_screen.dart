import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/provider/favorite_provider.dart';
import 'package:shop_app/provider/cart_provider.dart';
import 'package:shop_app/views/screens/detail/screens/product_detail_screen.dart';
import 'package:shop_app/services/manage_http_response.dart';

class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    final favoriteItemData = ref.watch(favoriteProvider);
    final favoriteItemProvider = ref.read(favoriteProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[800],
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  CupertinoIcons.heart,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      favoriteItemData.length.toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            height: 4.0,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[300]!, Colors.blue[500]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
      ),
      body:
          favoriteItemData.isEmpty
              ? _buildEmptyState()
              : _buildFavoriteList(favoriteItemData),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.heart, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Items you like will appear here',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteList(Map<dynamic, dynamic> favoriteItemData) {
    final favoriteItemProvider = ref.read(favoriteProvider.notifier);
    final CartProvider = ref.read(cartProvider.notifier);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: favoriteItemData.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final favoriteData = favoriteItemData.values.toList()[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.blue[100]!, width: 1),
          ),
          child: InkWell(
            // THÊM INKWELL ĐỂ NAVIGATE
            onTap: () {
              // Tạo Product object từ favorite data để navigate
              final product = Product(
                id: favoriteData.productId,
                productName: favoriteData.productName,
                productPrice: favoriteData.productPrice,
                quantity: favoriteData.productQuantity,
                description: favoriteData.description,
                category: favoriteData.category,
                vendorId: favoriteData.vendorId,
                fullName: favoriteData.fullName,
                subCategory: '', // Có thể thiếu trong favorite data
                images: favoriteData.image,
                averageRating: 0.0, // Có thể thiếu trong favorite data
                totalRating: 0, // Có thể thiếu trong favorite data
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(product: product),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 120,
              child: Row(
                children: [
                  // Product Image
                  Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Image.network(
                        favoriteData.image[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Product Details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Product Name
                          Text(
                            favoriteData.productName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // Bottom row with price and action buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Price
                              Text(
                                "${favoriteData.productPrice.toStringAsFixed(0)} VND",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),

                              // Action Buttons
                              Row(
                                children: [
                                  // Add to Cart Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        CupertinoIcons.cart_badge_plus,
                                        color: Colors.green[700],
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        // THÊM VÀO CART
                                        CartProvider.addProductToCart(
                                          productName: favoriteData.productName,
                                          productPrice:
                                              favoriteData.productPrice,
                                          category: favoriteData.category,
                                          image: favoriteData.image,
                                          vendorId: favoriteData.vendorId,
                                          productQuantity:
                                              favoriteData.productQuantity,
                                          quantity: 1,
                                          productId: favoriteData.productId,
                                          description: favoriteData.description,
                                          fullName: favoriteData.fullName,
                                        );

                                        showSnackBar(
                                          context,
                                          '${favoriteData.productName} added to cart',
                                        );
                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Remove from Favorites Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        CupertinoIcons.heart_slash,
                                        color: Colors.red[700],
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        favoriteItemProvider.removeFavoriteItem(
                                          favoriteData.productId,
                                        );

                                        showSnackBar(
                                          context,
                                          '${favoriteData.productName} removed from favorites',
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
