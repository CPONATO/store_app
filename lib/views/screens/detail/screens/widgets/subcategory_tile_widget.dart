import 'package:flutter/material.dart';

class SubcategoryTileWidget extends StatelessWidget {
  final String image;
  final String title;

  SubcategoryTileWidget({super.key, required this.image, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image container with shadow - Square shape
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
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
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.1),
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    image,
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
            ),
          ),

          const SizedBox(height: 8),

          // Title with fixed container size
          SizedBox(
            width: 80, // Match the image width
            height: 32, // Fixed height for text
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
                height: 1.2, // Line height
              ),
            ),
          ),
        ],
      ),
    );
  }
}
