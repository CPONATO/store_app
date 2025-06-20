import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/controllers/order_controller.dart';
import 'package:shop_app/models/order.dart';
import 'package:shop_app/provider/order_provider.dart';
import 'package:shop_app/provider/user_provider.dart';
import 'package:shop_app/views/screens/detail/screens/order_detail_screen.dart';
import 'package:shop_app/views/screens/main_screen.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  bool _isLoading = true;
  bool _isCriticalError = false; // Only for critical errors, not empty orders
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _isCriticalError = false;
      _errorMessage = null;
    });

    final user = ref.read(userProvider);
    if (user != null) {
      final OrderController orderController = OrderController();
      try {
        final orders = await orderController.loadOrders(buyerId: user.id);
        ref.read(orderProvider.notifier).setOrders(orders);

        // Không cần phải đưa ra thông báo lỗi nếu mảng orders rỗng
        // Đây là trường hợp bình thường và nên hiển thị màn hình "No orders"
      } catch (e) {
        print('Error fetching orders: $e');

        // Chỉ đặt _isCriticalError = true nếu đây là lỗi nghiêm trọng khác
        // không phải là trường hợp "không có đơn hàng"
        setState(() {
          _isCriticalError = true;
          _errorMessage = 'Could not load orders. Please try again.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please log in to view your orders';
      });
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    final OrderController orderController = OrderController();
    try {
      await orderController.deleteOrders(id: orderId, context: context);
      _fetchOrders();
    } catch (e) {
      print("Error Deleting Order: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[800],
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchOrders,
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
      body: RefreshIndicator(
        onRefresh: _fetchOrders,
        color: Colors.blue[700],
        child:
            _isLoading
                ? _buildLoadingState()
                : _isCriticalError
                ? _buildErrorState() // Only show for critical errors
                : orders.isEmpty
                ? _buildEmptyState()
                : _buildOrderList(orders),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue[700]),
          const SizedBox(height: 16),
          Text(
            'Loading your orders...',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Could not load orders. Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchOrders,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.cube_box,
              size: 60,
              color: Colors.blue[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Orders Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'You don\'t have any orders yet. Start shopping and your orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to shop/home screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return MainScreen();
                  },
                ),
              );
            },
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Start Shopping'),
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

  Widget _buildOrderList(List<Order> orders) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final Order order = orders[index];
        return _buildOrderItem(order);
      },
    );
  }

  Widget _buildOrderItem(Order order) {
    // Define status color based on order status
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (order.delivered) {
      statusColor = Colors.green[600]!;
      statusText = 'Delivered';
      statusIcon = Icons.check_circle;
    } else if (order.processing) {
      statusColor = Colors.blue[600]!;
      statusText = 'Processing';
      statusIcon = Icons.hourglass_top;
    } else {
      statusColor = Colors.red[600]!;
      statusText = 'Cancelled';
      statusIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order header with status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Order ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Placed on ${_formatDate(DateTime.now())}', // Replace with actual order date when available
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // Order status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Order item details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[200],
                    child: Image.network(
                      order.image,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (ctx, error, _) => Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey[400],
                              size: 30,
                            ),
                          ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.category,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${order.productPrice.toStringAsFixed(0)} VND',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Quantity: ${order.quantity}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Order actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Order total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${(order.productPrice * order.quantity).toStringAsFixed(0)} VND',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),

                // Action buttons
                Row(
                  children: [
                    // View details button
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return OrderDetailScreen(order: order);
                            },
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      label: Text(
                        'Details',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: Color.fromARGB(255, 5, 151, 0),
                      ),
                      label: const Text(
                        'Review',
                        style: TextStyle(
                          color: Color.fromARGB(255, 5, 151, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Delete button (conditional based on order status)
                    if (!order.delivered)
                      IconButton(
                        onPressed: () {
                          // Show confirmation dialog before deleting
                          _showDeleteConfirmation(context, order);
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[600],
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Cancel Order'),
            content: const Text(
              'Are you sure you want to cancel this order? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'No, Keep It',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _deleteOrder(order.id);
                  Navigator.of(ctx).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Yes, Cancel Order'),
              ),
            ],
          ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
