// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ProductReview {
  final String id;
  final String buyerId;
  final String email;
  final String productId;
  final double rating;
  final String fullName;
  final String review;

  ProductReview({
    required this.id,
    required this.buyerId,
    required this.email,
    required this.productId,
    required this.rating,
    required this.fullName,
    required this.review,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'buyerId': buyerId,
      'email': email,
      'productId': productId,
      'rating': rating,
      'fullName': fullName,
      'review': review,
    };
  }

  factory ProductReview.fromMap(Map<String, dynamic> map) {
    return ProductReview(
      id: map['_id'] as String,
      buyerId: map['buyerId'] as String,
      email: map['email'] as String,
      productId: map['productId'] as String,
      rating: map['rating'] as double,
      fullName: map['fullName'] as String,
      review: map['review'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProductReview.fromJson(String source) =>
      ProductReview.fromMap(json.decode(source) as Map<String, dynamic>);
}
