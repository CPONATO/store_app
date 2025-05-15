import 'package:flutter/material.dart';

class ReuseableTextWidget extends StatelessWidget {
  final String title;
  final String subTitle;

  const ReuseableTextWidget({
    super.key,
    required this.title,
    required this.subTitle,
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
            onPressed: () {},
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
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.blue[700],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
