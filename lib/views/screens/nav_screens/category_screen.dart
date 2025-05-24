import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/controllers/category_controller.dart';
import 'package:shop_app/controllers/subcategory_controller.dart';
import 'package:shop_app/models/category.dart';
import 'package:shop_app/models/subcategory.dart';
import 'package:shop_app/provider/category_provider.dart';
import 'package:shop_app/provider/subcategory_prodvider.dart';
import 'package:shop_app/views/screens/detail/screens/subcategory_product_screen.dart';
import 'package:shop_app/views/screens/detail/screens/widgets/subcategory_tile_widget.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/header_widget.dart';

class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({super.key});

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  Category? _selectedCategory;
  @override
  void initState() {
    super.initState();
    //load category imidiately

    _fetchCategory();
  }

  Future<void> _fetchCategory() async {
    final categories = await CategoryController().loadCategories();
    ref.read(categoryProvider.notifier).setCategory(categories);

    for (var category in categories) {
      if (category.name == "Fashion") {
        setState(() {
          _selectedCategory = category;
        });

        _fetchSubcategory(category.name);
      }
    }
  }

  Future<void> _fetchSubcategory(String categoryName) async {
    final subcategories = await SubcategoryController()
        .getSubCategoryByCategoryName(categoryName);
    ref.read(subcategoryProdvider.notifier).setSubcategories(subcategories);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final _subcategories = ref.watch(subcategoryProdvider);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.093,
        ),
        child: const HeaderWidget(),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side - Categories list
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = _selectedCategory == category;
                  return Container(
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.white,
                      border: Border(
                        left: BorderSide(
                          color:
                              isSelected
                                  ? Colors.blue[700]!
                                  : Colors.transparent,
                          width: 4,
                        ),
                      ),
                    ),
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                        _fetchSubcategory(category.name);
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      title: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.blue[700] : Colors.black87,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? Icon(
                                Icons.keyboard_arrow_right,
                                color: Colors.blue[700],
                              )
                              : null,
                    ),
                  );
                },
              ),
            ),
          ),

          // Right side - Subcategories and content
          Expanded(
            flex: 5,
            child:
                _selectedCategory != null
                    ? _buildCategoryContent()
                    : const Center(
                      child: Text(
                        'Select a category',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryContent() {
    final categories = ref.watch(categoryProvider);
    final subcategories = ref.watch(subcategoryProdvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _selectedCategory!.name,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),

          // Banner image with improved styling
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(_selectedCategory!.banner),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Subcategories section
          subcategories.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: subcategories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    crossAxisCount: 3,
                    childAspectRatio:
                        0.5, // Thay đổi từ 0.8 thành 0.7 để có thêm không gian chiều cao
                  ),
                  itemBuilder: (context, index) {
                    final subcategory = subcategories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SubcategoryProductScreen(
                                subcategory: subcategory,
                              );
                            },
                          ),
                        );
                      },
                      child: SubcategoryTileWidget(
                        image: subcategory.image,
                        title: subcategory.subCategoryName,
                      ),
                    );
                  },
                ),
              )
              : Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Subcategories Found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
