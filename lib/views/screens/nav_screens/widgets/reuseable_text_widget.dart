import 'package:flutter/material.dart';

class ReuseableTextWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final VoidCallback? onPressed; // Thêm callback cho navigation

  const ReuseableTextWidget({
    super.key,
    required this.title,
    required this.subTitle,
    this.onPressed, // Optional callback
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
          TextButton(
            onPressed: onPressed, // Sử dụng callback được truyền vào
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: Row(
              children: [
                Text(
                  subTitle,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
