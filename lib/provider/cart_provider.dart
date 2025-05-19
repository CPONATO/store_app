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
  CartNotifier() : super({}) {
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart_items');

    if (cartString != null) {
      final Map<String, dynamic> cartMap = jsonDecode(cartString);

      final carts = cartMap.map(
        (key, value) => MapEntry(key, Cart.fromJson(value)),
      );

      state = carts;
    }
  }

  Future<void> _saveCartItem() async {
    final prefs = await SharedPreferences.getInstance();

    final cartString = jsonEncode(state);

    await prefs.setString('cart_items', cartString);
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
    if (state.containsKey(productId)) {
      state[productId]!.quantity++;
      state = {...state};
      _saveCartItem();
    }
  }

  void decrementCartItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity--;
      state = {...state};
      _saveCartItem();
    }
  }

  void removeCartItem(String productId) {
    state.remove(productId);
    state = {...state};
    _saveCartItem();
  }

  // Thêm function mới để xóa toàn bộ giỏ hàng
  void clearCart() {
    state = {}; // Reset state thành map rỗng
    _saveCartItem(); // Lưu state mới vào SharedPreferences
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    state.forEach((productId, cartItem) {
      totalAmount += cartItem.quantity * cartItem.productPrice;
    });
    return totalAmount;
  }

  Map<String, Cart> get getCartItems => state;
}
