import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/product.dart';

class ProducProvider extends StateNotifier<List<Product>> {
  ProducProvider() : super([]);

  void setProduct(List<Product> products) {
    state = products;
  }
}

final producProvider = StateNotifierProvider<ProducProvider, List<Product>>((
  ref,
) {
  return ProducProvider();
});
