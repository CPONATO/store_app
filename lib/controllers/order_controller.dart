import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/global_variables.dart';
import 'package:shop_app/models/order.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/services/manage_http_response.dart';

class OrderController {
  Future<void> uploadOrders({
    required String id,
    required String fullName,
    required String email,
    required String state,
    required String city,
    required String locality,
    required String productName,
    required int productPrice,
    required int quantity,
    required String category,
    required String image,
    required String buyerId,
    required String vendorId,
    required String productId,
    required bool processing,
    required bool delivered,
    required context,
  }) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString("auth_token");
      final Order order = Order(
        id: id,
        fullName: fullName,
        email: email,
        state: state,
        city: city,
        locality: locality,
        productName: productName,
        productPrice: productPrice,
        quantity: quantity,
        category: category,
        image: image,
        buyerId: buyerId,
        vendorId: vendorId,
        productId: productId, // Thêm vào khi tạo Order
        processing: processing,
        delivered: delivered,
      );

      http.Response response = await http.post(
        Uri.parse("$uri/api/orders"),
        body: order.toJson(),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );

      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, "Order Successfully Placed");
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future<List<Order>> loadOrders({required String buyerId}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString("auth_token");
      http.Response response = await http.get(
        Uri.parse('$uri/api/orders/$buyerId'),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Order> orders =
            data.map((order) => Order.fromJson(order)).toList();
        return orders;
      } else if (response.statusCode == 404) {
        // Đây là trường hợp bình thường khi không có đơn hàng
        return []; // Trả về mảng rỗng
      } else {
        throw Exception('Failed to load Orders: Status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error Loading Orders: $e');
    }
  }

  // Thêm function mới để đếm số đơn hàng đã giao
  Future<int> getDeliveredOrderCount({required String buyerId}) async {
    try {
      List<Order> orders = await loadOrders(buyerId: buyerId);
      int deliveredCount = orders.where((order) => order.delivered).length;
      return deliveredCount;
    } catch (e) {
      // Nếu có lỗi, trả về 0
      return 0;
    }
  }

  Future<void> deleteOrders({required String id, required context}) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      String? token = preferences.getString("auth_token");
      http.Response response = await http.delete(
        Uri.parse("$uri/api/orders/$id"),
        headers: <String, String>{
          "Content-Type": 'application/json; charset=UTF-8',
          'x-auth-token': token!,
        },
      );
      manageHttpResponse(
        response: response,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Order Deleted');
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // Future<Map<String, dynamic>> createPaymentItent({
  //   required int amount,
  //   required String currency,
  // }) async {
  //   try {
  //     SharedPreferences preferences = await SharedPreferences.getInstance();
  //     String? token = preferences.getString("auth_token");

  //     http.Response response = await http.post(
  //       Uri.parse('$uri/api/payment-intent'),
  //       headers: <String, String>{
  //         "Content-Type": 'application/json; charset=UTF-8',
  //         'x-auth-token': token!,
  //       },
  //       body: jsonEncode({"amount": amount, "currency": currency}),
  //     );
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       throw Exception("Failed to create payment intent${response.body}");
  //     }
  //   } catch (e) {
  //     throw Exception('Error creating payment intent: $e');
  //   }
  // }
}
