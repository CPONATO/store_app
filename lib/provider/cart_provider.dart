import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/cart.dart';

final cartProvider = StateNotifierProvider<CartNotifier, Map<String, Cart>>((
  ref,
) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Map<String, Cart>> {
  CartNotifier() : super({});

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
    print("Adding product to cart with ID: $productId");
    if (state.containsKey(productId)) {
      state = {
        ...state,
        productId: Cart(
          productName: state[productId]!.productName,
          productPrice: state[productId]!.productPrice,
          category: state[productId]!.category,
          image: state[productId]!.image,
          vendorId: state[productId]!.vendorId,
          productQuantity: state[productId]!.productQuantity,
          quantity: state[productId]!.quantity + 1,
          productId: state[productId]!.productId,
          description: state[productId]!.description,
          fullName: state[productId]!.fullName,
        ),
      };
    } else {
      state = {
        ...state,
        productId: Cart(
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
        ),
      };
    }
  }

  void incrementCartItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity++;

      state = {...state};
    }
  }

  void decrementCartItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity--;

      state = {...state};
    }
  }

  void removeCartItem(String productId) {
    state.remove(productId);
    state = {...state};
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
