import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/controllers/auth_controller.dart';
import 'package:shop_app/provider/cart_provider.dart';
import 'package:shop_app/provider/favorite_provider.dart';
import 'package:shop_app/provider/order_provider.dart';
import 'package:shop_app/provider/user_provider.dart';
import 'package:shop_app/provider/delivered_order_count_provider.dart';
import 'package:shop_app/views/screens/detail/screens/order_screen.dart';
import 'package:shop_app/views/screens/detail/screens/shipping_address_screen.dart';

class AccountScreen extends ConsumerStatefulWidget {
  AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final AuthController _authController = AuthController();
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeDeliveredOrderCount();
  }

  void _initializeDeliveredOrderCount() {
    final user = ref.read(userProvider);
    if (user != null && !_hasInitialized) {
      _hasInitialized = true;
      // Fetch delivered order count khi màn hình được load
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(deliveredOrderCountProvider.notifier)
            .fetchDeliveredOrderCount(user.id, context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final cartItems = ref.watch(cartProvider);
    final favoriteItems = ref.watch(favoriteProvider);
    final deliveredOrderCount = ref.watch(
      deliveredOrderCountProvider,
    ); // Watch provider của bạn

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[800],
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              // Navigate to settings if needed
            },
          ),
          // Thêm refresh button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Refresh delivered order count
              ref
                  .read(deliveredOrderCountProvider.notifier)
                  .fetchDeliveredOrderCount(user.id, context);
            },
          ),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, user),
            const SizedBox(height: 16),

            // Sử dụng deliveredOrderCount từ provider
            _buildStatisticsSection(
              context,
              cartCount: cartItems.length,
              favoriteCount: favoriteItems.length,
              orderCount: deliveredOrderCount, // Sử dụng provider value
            ),
            const SizedBox(height: 16),

            _buildSectionTitle('Account Information'),
            _buildInfoCard(context, user),
            const SizedBox(height: 16),
            _buildSectionTitle('Address'),
            _buildAddressCard(context, user, ref),
            const SizedBox(height: 16),
            _buildSectionTitle('Security'),
            _buildSecurityCard(context),
            const SizedBox(height: 16),

            _buildSectionTitle('Support'),
            _buildContactSupportCard(context),
            const SizedBox(height: 24),

            _buildSignOutButton(context),
            const SizedBox(height: 12),
            _buildDeleteAccountButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[100],
              border: Border.all(color: Colors.blue[700]!, width: 2),
            ),
            child: Center(
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    'Customer',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context, {
    required int cartCount,
    required int favoriteCount,
    required int orderCount,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Giỏ hàng
          Expanded(
            child: _buildStatItem(
              icon: CupertinoIcons.cart,
              color: Colors.blue,
              title: 'Cart',
              count: cartCount,
              onTap: () {
                // Navigate to cart if needed
              },
            ),
          ),
          // Đường kẻ phân cách
          Container(height: 50, width: 1, color: Colors.grey[200]),
          // Yêu thích
          Expanded(
            child: _buildStatItem(
              icon: CupertinoIcons.heart,
              color: Colors.red,
              title: 'Favorites',
              count: favoriteCount,
              onTap: () {
                // Navigate to favorites if needed
              },
            ),
          ),
          // Đường kẻ phân cách
          Container(height: 50, width: 1, color: Colors.grey[200]),
          // Đơn hàng đã giao
          Expanded(
            child: _buildStatItem(
              icon: CupertinoIcons.cube_box,
              color: Colors.green,
              title: 'Delivered',
              count: orderCount,
              onTap: () {
                // Refresh delivered order count khi tap
                final user = ref.read(userProvider);
                if (user != null) {
                  ref
                      .read(deliveredOrderCountProvider.notifier)
                      .fetchDeliveredOrderCount(user.id, context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String title,
    required int count,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: Color(0xFF2196F3), size: 24),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1565C0),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            title: 'Full Name',
            subtitle: user.fullName,
            icon: CupertinoIcons.person_fill,
            iconColor: Colors.blue[700]!,
            onTap: () {
              // Navigate to edit name screen if needed
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            title: 'Email',
            subtitle: user.email,
            icon: CupertinoIcons.mail_solid,
            iconColor: Colors.green[700]!,
            onTap: () {
              // Navigate to email settings if needed
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            title: 'Order',
            subtitle: 'Your Orders',
            icon: CupertinoIcons.cart,
            iconColor: Colors.orange[700]!,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return OrderScreen();
                  },
                ),
              ).then((_) {
                // Refresh delivered order count khi quay lại từ OrderScreen
                final user = ref.read(userProvider);
                if (user != null) {
                  ref
                      .read(deliveredOrderCountProvider.notifier)
                      .fetchDeliveredOrderCount(user.id, context);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, dynamic user, WidgetRef ref) {
    final hasAddress =
        user.state.isNotEmpty ||
        user.city.isNotEmpty ||
        user.locality.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ShippingAddressScreen(),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.location_solid,
                    color: Colors.blue[700],
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasAddress
                            ? 'Shipping Address'
                            : 'Add Shipping Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: hasAddress ? Colors.black : Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (hasAddress)
                        Text(
                          '${user.locality}, ${user.city}, ${user.state}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        )
                      else
                        Text(
                          'Tap to add your shipping address',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildListTile(
        title: 'Change Password',
        subtitle: 'Last changed 30 days ago',
        icon: CupertinoIcons.lock_fill,
        iconColor: Colors.purple[700]!,
        onTap: () {
          // Navigate to change password screen if needed
        },
      ),
    );
  }

  Widget _buildContactSupportCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            title: 'Contact Support',
            subtitle: '24/7 Customer Service',
            icon: CupertinoIcons.chat_bubble_text,
            iconColor: Colors.teal[700]!,
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Contact Support'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContactItem(
                            icon: Icons.email,
                            title: 'Email',
                            details: 'RielEmail@gmail.com',
                          ),
                          SizedBox(height: 16),
                          _buildContactItem(
                            icon: Icons.phone,
                            title: 'Phone',
                            details: '+84 888-123-567',
                          ),
                          SizedBox(height: 16),
                          _buildContactItem(
                            icon: Icons.schedule,
                            title: 'Working Hours',
                            details: 'Monday to Sunday, 24/7',
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
          const Divider(height: 1),
          _buildListTile(
            title: 'FAQ',
            subtitle: 'Frequently Asked Questions',
            icon: CupertinoIcons.question_circle,
            iconColor: Colors.amber[700]!,
            onTap: () {
              // Điều hướng đến màn hình FAQ
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String details,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: 24),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              details,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Confirm Sign Out'),
                  content: const Text(
                    'Signing out will clear all login data on this device. Are you sure you want to continue?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);

                        _authController.signOutUSer(context: context);
                      },
                      child: const Text('Sign Out'),
                    ),
                  ],
                ),
          );
        },
        icon: const Icon(Icons.logout),
        label: const Text(
          'Sign Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 124, 63),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(BuildContext context) {
    final user = ref.read(userProvider);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Delete Account'),
                  content: const Text(
                    'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
                    style: TextStyle(color: Colors.black87),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        _authController.deleteAccoumt(
                          context: context,
                          id: user!.id,
                          ref: ref,
                        );
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
          );
        },
        icon: const Icon(Icons.delete_forever),
        label: const Text(
          'Delete Account',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[800],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
