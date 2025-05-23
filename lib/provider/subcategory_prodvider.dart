import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/subcategory.dart';

class SubcategoryProdvider extends StateNotifier<List<Subcategory>> {
  SubcategoryProdvider() : super([]);

  void setSubcategories(List<Subcategory> subcategories) {
    state = subcategories;
  }
}

final subcategoryProdvider =
    StateNotifierProvider<SubcategoryProdvider, List<Subcategory>>((ref) {
      return SubcategoryProdvider();
    });
