import 'package:flutter/material.dart';
import 'package:shop_app/models/order.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          order.productName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
