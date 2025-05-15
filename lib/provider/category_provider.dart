import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/category.dart';

class CategoryProvider extends StateNotifier<List<Category>> {
  CategoryProvider() : super([]);

  void setCategory(List<Category> categories) {
    state = categories;
  }
}

final categoryProvider =
    StateNotifierProvider<CategoryProvider, List<Category>>((ref) {
      return CategoryProvider();
    });
