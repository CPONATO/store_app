import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/controllers/category_controller.dart';
import 'package:shop_app/models/category.dart';
import 'package:shop_app/provider/category_provider.dart';
import 'package:shop_app/views/screens/detail/screens/inner_category_screen.dart';

class CategoryItemWidget extends ConsumerStatefulWidget {
  const CategoryItemWidget({super.key});

  @override
  _CategoryItemWidgetState createState() => _CategoryItemWidgetState();
}

class _CategoryItemWidgetState extends ConsumerState<CategoryItemWidget> {
  @override
  void initState() {
    super.initState();
    _fetchCategory();
  }

  Future<void> _fetchCategory() async {
    final CategoryController categoryController = CategoryController();
    try {
      final categories = await categoryController.loadCategories();
      ref.read(categoryProvider.notifier).setCategory(categories);
    } catch (e) {
      print('$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);

    return Container(
      height: 120, // Chiều cao cố định cho container
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Scroll ngang
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryItem(context, category);
        },
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category) {
    return Container(
      width: 90, // Chiều rộng cố định cho mỗi item
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => InnerCategoryScreen(category: category),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Image.network(
                  category.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.grey[400],
                        size: 30,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
