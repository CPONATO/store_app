import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/product.dart';

class SubcategoryProductProvider extends StateNotifier<List<Product>> {
  SubcategoryProductProvider() : super([]);

  void setProduct(List<Product> products) {
    state = products;
  }
}

final subcategoryProductProvider =
    StateNotifierProvider<SubcategoryProductProvider, List<Product>>((ref) {
      return SubcategoryProductProvider();
    });
