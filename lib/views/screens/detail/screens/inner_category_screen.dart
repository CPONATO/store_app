import 'package:flutter/material.dart';
import 'package:shop_app/models/category.dart';
import 'package:shop_app/views/screens/detail/screens/widgets/inner_category_content_widget.dart';

class InnerCategoryScreen extends StatefulWidget {
  final Category category;

  const InnerCategoryScreen({super.key, required this.category});

  @override
  State<InnerCategoryScreen> createState() => _InnerCategoryScreenState();
}

class _InnerCategoryScreenState extends State<InnerCategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: InnerCategoryContentWidget(category: widget.category),
    );
  }
}
