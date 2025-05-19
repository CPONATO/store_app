import 'dart:convert';

import 'package:shop_app/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/global_variables.dart';

class ProductController {
  Future<List<Product>> loadPopularProduct() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/popular-product'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Product> products =
            data
                .map(
                  (product) => Product.fromMap(product as Map<String, dynamic>),
                )
                .toList();
        return products;
      } else {
        throw Exception('Failed To Load Products');
      }
    } catch (e) {
      throw Exception('Error Loading Product: $e');
    }
  }

  Future<List<Product>> loadProductByCategory(String category) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/products-by-category/$category'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Product> products =
            data
                .map(
                  (product) => Product.fromMap(product as Map<String, dynamic>),
                )
                .toList();
        return products;
      } else {
        throw Exception('Failed To Load Products');
      }
    } catch (e) {
      throw Exception('Error Loading Product: $e');
    }
  }

  //display related product by subcategory

  Future<List<Product>> loadRelatedProductBySubcategory(
    String productId,
  ) async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/related-products-by-subcategory/$productId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Product> topRatedProduct =
            data
                .map(
                  (product) => Product.fromMap(product as Map<String, dynamic>),
                )
                .toList();
        return topRatedProduct;
      } else {
        throw Exception('Failed To Load related Products');
      }
    } catch (e) {
      throw Exception('Error Loading related Products: $e');
    }
  }

  // get top 10 highest rated product

  Future<List<Product>> loadtop10Product() async {
    try {
      http.Response response = await http.get(
        Uri.parse('$uri/api/top-rated-products'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        List<Product> topRatedProduct =
            data
                .map(
                  (product) => Product.fromMap(product as Map<String, dynamic>),
                )
                .toList();
        return topRatedProduct;
      } else {
        throw Exception('Failed To Load  Products');
      }
    } catch (e) {
      throw Exception('Error Loading  Products: $e');
    }
  }
}
