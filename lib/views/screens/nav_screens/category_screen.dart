import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/controllers/category_controller.dart';
import 'package:shop_app/controllers/subcategory_controller.dart';
import 'package:shop_app/models/category.dart';
import 'package:shop_app/models/subcategory.dart';
import 'package:shop_app/views/screens/detail/screens/widgets/subcategory_tile_widget.dart';
import 'package:shop_app/views/screens/nav_screens/widgets/header_widget.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late Future<List<Category>> futureCategories;
  List<Subcategory> _subcategegories = [];
  final SubcategoryController _subcategoryController = SubcategoryController();
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    futureCategories = CategoryController().loadCategories();
    futureCategories.then((categories) {
      for (var category in categories) {
        if (category.name == "Fashion") {
          setState(() {
            _selectedCategory = category;
          });
          _loadSubcategories(category.name);
        }
      }
    });
  }

  Future<void> _loadSubcategories(String categoryName) async {
    final subcategories = await _subcategoryController
        .getSubCategoryByCategoryName(categoryName);
    setState(() {
      _subcategegories = subcategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(
          98,
        ), // Điều chỉnh chiều cao cho HeaderWidget
        child: HeaderWidget(),
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
              child: FutureBuilder(
                future: futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final categories = snapshot.data!;
                    return ListView.builder(
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
                              _loadSubcategories(category.name);
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
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isSelected
                                        ? Colors.blue[700]
                                        : Colors.black87,
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
                    );
                  }
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Subcategories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
          ),

          _subcategegories.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _subcategegories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    crossAxisCount: 3,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final subcategory = _subcategegories[index];
                    return SubcategoryTileWidget(
                      image: subcategory.image,
                      title: subcategory.categoryName,
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
