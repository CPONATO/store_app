import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/cart.dart';

final cartProvider = StateNotifierProvider<CartNotifier, Map<String, Cart>>((
  ref,
) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Map<String, Cart>> {
  CartNotifier() : super({});

  String? _currentUserId;

  // Load cart items for specific user
  Future<void> loadCartItemsForUser(String userId) async {
    _currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart_items_$userId');

    if (cartString != null) {
      try {
        final Map<String, dynamic> cartMap = jsonDecode(cartString);
        final carts = cartMap.map(
          (key, value) => MapEntry(key, Cart.fromJson(value)),
        );
        state = carts;
      } catch (e) {
        print('Error loading cart for user $userId: $e');
        state = {};
      }
    } else {
      state = {};
    }
  }

  // Save cart items for current user
  Future<void> _saveCartItem() async {
    if (_currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final cartString = jsonEncode(state);
    await prefs.setString('cart_items_$_currentUserId', cartString);
  }

  // Clear cart for current user
  Future<void> clearCartForUser() async {
    if (_currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_items_$_currentUserId');
    state = {};
  }

  // Clear all cart data (chỉ dùng khi cần thiết, không dùng khi sign out)
  Future<void> clearAllCartData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    // Remove all cart-related keys
    for (String key in keys) {
      if (key.startsWith('cart_items_')) {
        await prefs.remove(key);
      }
    }

    _currentUserId = null;
    state = {};
  }

  // Reset cart state khi đăng xuất (chỉ clear state, không xóa SharedPreferences)
  void resetCartState() {
    _currentUserId = null;
    state = {};
  }

  void addProductToCart({
    required String productName,
    required int productPrice,
    required String category,
    required List<String> image,
    required String vendorId,
    required int productQuantity,
    required int quantity,
    required String productId,
    required String description,
    required String fullName,
  }) {
    if (_currentUserId == null) {
      print('Warning: No user logged in, cannot add to cart');
      return;
    }

    // Tạo bản sao của state hiện tại
    final updatedState = Map<String, Cart>.from(state);

    if (updatedState.containsKey(productId)) {
      // Tăng số lượng nếu sản phẩm đã tồn tại
      final existingItem = updatedState[productId]!;
      updatedState[productId] = Cart(
        productName: existingItem.productName,
        productPrice: existingItem.productPrice,
        category: existingItem.category,
        image: existingItem.image,
        vendorId: existingItem.vendorId,
        productQuantity: existingItem.productQuantity,
        quantity: existingItem.quantity + 1,
        productId: existingItem.productId,
        description: existingItem.description,
        fullName: existingItem.fullName,
      );
    } else {
      // Thêm sản phẩm mới
      updatedState[productId] = Cart(
        productName: productName,
        productPrice: productPrice,
        category: category,
        image: image,
        vendorId: vendorId,
        productQuantity: productQuantity,
        quantity: quantity,
        productId: productId,
        description: description,
        fullName: fullName,
      );
    }

    state = updatedState;
    _saveCartItem();
  }

  void incrementCartItem(String productId) {
    if (_currentUserId == null) return;

    if (state.containsKey(productId)) {
      state[productId]!.quantity++;
      state = {...state};
      _saveCartItem();
    }
  }

  void decrementCartItem(String productId) {
    if (_currentUserId == null) return;

    if (state.containsKey(productId)) {
      if (state[productId]!.quantity > 1) {
        state[productId]!.quantity--;
      } else {
        // Remove item if quantity becomes 0
        removeCartItem(productId);
        return;
      }
      state = {...state};
      _saveCartItem();
    }
  }

  void removeCartItem(String productId) {
    if (_currentUserId == null) return;

    state.remove(productId);
    state = {...state};
    _saveCartItem();
  }

  // Clear cart but keep user context
  void clearCart() {
    if (_currentUserId == null) return;

    state = {};
    _saveCartItem();
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    state.forEach((productId, cartItem) {
      totalAmount += cartItem.quantity * cartItem.productPrice;
    });
    return totalAmount;
  }

  Map<String, Cart> get getCartItems => state;

  String? get currentUserId => _currentUserId;
}
