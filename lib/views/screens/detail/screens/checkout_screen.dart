import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shop_app/controllers/order_controller.dart';
import 'package:shop_app/models/order.dart';
import 'package:shop_app/provider/cart_provider.dart';
import 'package:shop_app/provider/user_provider.dart';
import 'package:shop_app/services/manage_http_response.dart';
import 'package:shop_app/views/screens/detail/screens/shipping_address_screen.dart';
import 'package:shop_app/views/screens/main_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String selectedPaymentMethod = 'Cash On Delivery';
  // Future<void> handleStripePayment(BuildContext context) async {
  //   final OrderController _orderController = OrderController();
  //   final cartData = ref.read(cartProvider);
  //   final user = ref.read(userProvider);
  //   bool isloading = false;

  //   if (cartData.isEmpty) {
  //     showSnackBar(context, "Your cart is empty");
  //     return;
  //   }

  //   if (user == null) {
  //     showSnackBar(context, "User information is missing");
  //     return;
  //   }

  //   try {
  //     setState(() {
  //       isloading = true;
  //     });
  //     //calculate the total amount for all item in cart
  //     final totalAmount = cartData.values.fold(
  //       0.0,
  //       (sum, item) => sum + (item.quantity * item.productPrice),
  //     );
  //     //check if the total amount is a valid amount
  //     if (totalAmount <= 0) {
  //       showSnackBar(context, "Total amount must be greater than 0");
  //       return;
  //     }
  //     final paymentItent = await _orderController.createPaymentItent(
  //       amount: (totalAmount * 100).toInt(),
  //       currency: 'usd',
  //     );

  //     await Stripe.instance.initPaymentSheet(
  //       paymentSheetParameters: SetupPaymentSheetParameters(
  //         paymentIntentClientSecret: paymentItent['client_secret'],
  //         merchantDisplayName: 'K Store',
  //       ),
  //     );

  //     await Stripe.instance.presentPaymentSheet();
  //     for (final entry in cartData.entries) {
  //       final item = entry.value;
  //       await _orderController.uploadOrders(
  //         id: '',
  //         fullName: ref.read(userProvider)!.fullName,
  //         email: ref.read(userProvider)!.email,
  //         state: ref.read(userProvider)!.state,
  //         city: ref.read(userProvider)!.city,
  //         locality: ref.read(userProvider)!.locality,
  //         productName: item.productName,
  //         productPrice: item.productPrice,
  //         quantity: item.quantity,
  //         category: item.category,
  //         image: item.image[0],
  //         buyerId: ref.read(userProvider)!.id,
  //         vendorId: item.vendorId,
  //         processing: true,
  //         delivered: false,
  //         productId: item.productId,
  //         context: context,
  //       );
  //     }
  //   } catch (e) {
  //     showSnackBar(context, 'Payment failed: $e');
  //   } finally {
  //     isloading = false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final cartData = ref.read(cartProvider);
    print("Cart data: $cartData");

    // Kiểm tra chi tiết từng sản phẩm trong giỏ hàng
    cartData.forEach((key, value) {
      print(
        "Product ID: $key, Product Name: ${value.productName}, ProductID trong value: ${value.productId}",
      );
    });
    final totalAmount = ref.read(cartProvider.notifier).calculateTotalAmount();
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Shipping Address'),
            _buildAddressCard(),
            _buildSectionTitle('Your Items'),
            _buildItemsList(cartData),
            _buildSectionTitle('Payment Method'),
            _buildPaymentOptions(),
            _buildOrderSummary(totalAmount),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomCheckoutBar(totalAmount),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildAddressCard() {
    final user = ref.watch(userProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return ShippingAddressScreen();
                },
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.location_solid,
                    color: Colors.blue[700],
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Address text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      user!.state.isNotEmpty
                          ? Text(
                            'Address',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          )
                          : Text(
                            'Add or Edit Address',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                      const SizedBox(height: 4),
                      user.state.isNotEmpty
                          ? Text(
                            user.state,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                          : Text(
                            'Enter your state',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      user.city.isNotEmpty
                          ? Text(
                            user.city,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          )
                          : const SizedBox.shrink(),

                      const SizedBox(height: 2),
                      user.locality.isNotEmpty
                          ? Text(
                            user.locality,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          )
                          : Text(
                            'Enter your city and address details',
                            style: TextStyle(
                              fontSize: 12,
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

  Widget _buildItemsList(Map<String, dynamic> cartData) {
    if (cartData.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            children: [
              Icon(CupertinoIcons.cart, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: cartData.length,
      itemBuilder: (context, index) {
        final cartItem = cartData.values.toList()[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.network(
                      cartItem.image[0],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Product details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartItem.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cartItem.category,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'Qty: ${cartItem.quantity}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${cartItem.productPrice.toStringAsFixed(0)} VND',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _buildPaymentOption(
            title: 'Credit/Debit Card (Stripe)',
            icon: Icons.credit_card,
            value: 'stripe',
            subtitle: 'Pay securely with your card (in development)',
          ),
          Divider(color: Colors.grey[200]),
          _buildPaymentOption(
            title: 'Cash on Delivery',
            icon: CupertinoIcons.money_dollar_circle,
            value: 'Cash On Delivery',
            subtitle: 'Pay when you receive your items',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required IconData icon,
    required String value,
    required String subtitle,
  }) {
    final isSelected = selectedPaymentMethod == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            selectedPaymentMethod = value;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue[700] : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected ? Colors.blue[800] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.blue[700]! : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue[700],
                            ),
                          ),
                        )
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double totalAmount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Subtotal', '${totalAmount.toStringAsFixed(0)} VND'),
          const SizedBox(height: 8),
          _buildSummaryRow('Shipping', '20000 VND'),
          const SizedBox(height: 8),

          Divider(color: Colors.grey[300]),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Total',
            '${(totalAmount + 20000).toStringAsFixed(0)} VND',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? Colors.blue[800] : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCheckoutBar(double totalAmount) {
    final _cartProvider = ref.read(cartProvider.notifier);
    final OrderController _orderController = OrderController();
    final user = ref.watch(userProvider);
    final finalTotal = totalAmount + 20000;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "${finalTotal.toStringAsFixed(0)} VND",
                  style: TextStyle(
                    color: Colors.blue[800],
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child:
                  user!.state.isEmpty
                      ? TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ShippingAddressScreen();
                              },
                            ),
                          );
                        },
                        child: Text(
                          "Please Enter Shipping Address",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.7,
                          ),
                        ),
                      )
                      : ElevatedButton(
                        onPressed: () async {
                          print("=== STARTING ORDER PROCESS ===");

                          // KIỂM TRA CÁC ĐIỀU KIỆN CƠ BẢN
                          final cartItems = _cartProvider.getCartItems;
                          print("Cart items count: ${cartItems.length}");
                          print("User ID: ${user.id}");
                          print("User state: ${user.state}");
                          print("User city: ${user.city}");
                          print("User locality: ${user.locality}");

                          if (cartItems.isEmpty) {
                            showSnackBar(context, "Cart is empty!");
                            return;
                          }

                          if (user.id.isEmpty) {
                            showSnackBar(context, "User ID is missing!");
                            return;
                          }

                          // HIỂN THỊ LOADING
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (context) => AlertDialog(
                                  content: Row(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 20),
                                      Text("Creating orders..."),
                                    ],
                                  ),
                                ),
                          );

                          try {
                            // TEST VỚI CHỈ 1 SẢN PHẨM ĐẦU TIÊN
                            final firstItem = cartItems.values.first;

                            print("--- UPLOADING FIRST ITEM ---");
                            print("Product Name: ${firstItem.productName}");
                            print("Product ID: ${firstItem.productId}");
                            print("Product Price: ${firstItem.productPrice}");
                            print("Quantity: ${firstItem.quantity}");
                            print("Vendor ID: ${firstItem.vendorId}");
                            print("Category: ${firstItem.category}");
                            print("Image: ${firstItem.image[0]}");

                            await _orderController.uploadOrders(
                              id: '',
                              fullName: user.fullName,
                              email: user.email,
                              state: user.state,
                              city: user.city,
                              locality: user.locality,
                              productName: firstItem.productName,
                              productPrice: firstItem.productPrice,
                              quantity: firstItem.quantity,
                              category: firstItem.category,
                              image: firstItem.image[0],
                              buyerId: user.id,
                              vendorId: firstItem.vendorId,
                              processing: true,
                              delivered: false,
                              productId: firstItem.productId,
                              context: context,
                            );

                            print("✅ ORDER UPLOADED SUCCESSFULLY");

                            // Đóng loading
                            Navigator.of(context).pop();

                            // Thông báo thành công
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text("Success!"),
                                    content: Text(
                                      "Order created successfully!\n\nProduct: ${firstItem.productName}",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();

                                          // CHỈ CLEAR CART SAU KHI THÀNH CÔNG
                                          _cartProvider.clearCart();

                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => MainScreen(),
                                            ),
                                          );
                                        },
                                        child: Text("OK"),
                                      ),
                                    ],
                                  ),
                            );
                          } catch (e, stackTrace) {
                            print("❌ ERROR CREATING ORDER: $e");
                            print("Stack trace: $stackTrace");

                            // Đóng loading
                            Navigator.of(context).pop();

                            // Hiển thị lỗi chi tiết
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text("Order Failed"),
                                    content: Text(
                                      "Error: $e\n\nPlease check your internet connection and try again.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(context).pop(),
                                        child: Text("OK"),
                                      ),
                                    ],
                                  ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            25,
                            118,
                            210,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Place Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
