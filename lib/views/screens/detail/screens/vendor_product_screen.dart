import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/controllers/product_controller.dart';
import 'package:shop_app/models/vendor_model.dart';
import 'package:shop_app/provider/vendor_product_provider.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/product_item_widget.dart';

class VendorProductScreen extends ConsumerStatefulWidget {
  final Vendor vendor;

  const VendorProductScreen({super.key, required this.vendor});

  @override
  ConsumerState<VendorProductScreen> createState() =>
      _VendorProductScreenState();
}

class _VendorProductScreenState extends ConsumerState<VendorProductScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchProduct();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchProduct() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final ProductController productController = ProductController();
    try {
      final products = await productController.loadProductByVendor(
        widget.vendor.id,
      );
      if (mounted) {
        ref.read(vendorProductProvider.notifier).setProduct(products);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to load products. Please try again.';
        });
      }
      debugPrint('Error fetching products: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(vendorProductProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        screenWidth < 600
            ? 2
            : screenWidth < 900
            ? 3
            : 4;
    final childAspectRatio = screenWidth < 600 ? 0.7 : 0.8;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(products.length),
      body: RefreshIndicator(
        onRefresh: _fetchProduct,
        child: _buildBody(crossAxisCount, childAspectRatio, products),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int productCount) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue[800],
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        widget.vendor.fullName ?? 'Store',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                CupertinoIcons.bell,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () {},
              tooltip: 'Notifications',
            ),
            if (productCount > 0)
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
                      productCount > 99 ? '99+' : productCount.toString(),
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
        const SizedBox(width: 16),
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
    );
  }

  Widget _buildBody(
    int crossAxisCount,
    double childAspectRatio,
    List products,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildVendorHeader()),
        if (_isLoading && products.isEmpty)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          SliverFillRemaining(child: _buildErrorWidget())
        else if (products.isEmpty)
          SliverFillRemaining(child: _buildEmptyWidget())
        else
          _buildProductGrid(crossAxisCount, childAspectRatio, products),
      ],
    );
  }

  Widget _buildVendorHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Hero(
            tag: 'vendor_${widget.vendor.id}',
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  widget.vendor.storeImage != null &&
                          widget.vendor.storeImage!.isNotEmpty
                      ? NetworkImage(widget.vendor.storeImage!)
                      : null,
              child:
                  widget.vendor.storeImage == null ||
                          widget.vendor.storeImage!.isEmpty
                      ? Icon(Icons.store, size: 60, color: Colors.grey[600])
                      : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.vendor.fullName ?? 'No name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.vendor.storeDescription != null &&
              widget.vendor.storeDescription!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Text(
                widget.vendor.storeDescription!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[800],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 24),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey[300]!,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(
    int crossAxisCount,
    double childAspectRatio,
    List products,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final product = products[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ProductItemWidget(product: product),
          );
        }, childCount: products.length),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchProduct,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No products available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This store has no products to display',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _fetchProduct,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue[800]),
            ),
          ],
        ),
      ),
    );
  }
}
