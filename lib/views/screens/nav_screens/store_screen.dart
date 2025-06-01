import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/controllers/vendor_controller.dart';
import 'package:shop_app/provider/vendor_provider.dart';
import 'package:shop_app/views/screens/detail/screens/vendor_product_screen.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchVendor();
  }

  Future<void> _fetchVendor() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final VendorController vendorController = VendorController();
    try {
      final vendors = await vendorController.loadVendors();
      if (mounted) {
        ref.read(vendorProvider.notifier).setVendors(vendors);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to load stores. Please try again.';
        });
      }
      debugPrint('Error fetching vendors: $e');
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
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        screenWidth < 600
            ? 2
            : screenWidth < 900
            ? 3
            : 4;
    final childAspectRatio = screenWidth < 600 ? 0.8 : 0.85;
    final vendors = ref.watch(vendorProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(vendors.length),
      body: RefreshIndicator(
        onRefresh: _fetchVendor,
        child: _buildBody(crossAxisCount, childAspectRatio, vendors),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(int vendorCount) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue[800],
      title: const Text(
        'Stores',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
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
            if (vendorCount > 0)
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
                      vendorCount > 99 ? '99+' : vendorCount.toString(),
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

  Widget _buildBody(int crossAxisCount, double childAspectRatio, List vendors) {
    if (_isLoading && vendors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    if (vendors.isEmpty) {
      return _buildEmptyWidget();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: vendors.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final vendor = vendors[index];
          return _buildVendorCard(vendor);
        },
      ),
    );
  }

  Widget _buildVendorCard(vendor) {
    return Card(
      elevation: 4,
      color: Colors.white, // Thêm dòng này để đảm bảo card có màu trắng
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorProductScreen(vendor: vendor),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Màu nền cho container bên trong
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'vendor_${vendor.id}',
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        vendor.storeImage != null &&
                                vendor.storeImage!.isNotEmpty
                            ? NetworkImage(vendor.storeImage!)
                            : null,
                    child:
                        vendor.storeImage == null || vendor.storeImage!.isEmpty
                            ? Icon(
                              Icons.store,
                              size: 40,
                              color: Colors.grey[600],
                            )
                            : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  vendor.fullName ?? 'No name',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (vendor.storeDescription != null &&
                    vendor.storeDescription!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    vendor.storeDescription!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
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
              onPressed: _fetchVendor,
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
            Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No stores available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
