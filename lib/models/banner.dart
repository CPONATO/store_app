// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class BannerModel {
  final String id;
  final String image;

  BannerModel({required this.id, required this.image});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'image': image};
  }

  factory BannerModel.fromJson(Map<String, dynamic> map) {
    return BannerModel(id: map['_id'] as String, image: map['image'] as String);
  }

  String toJson() => json.encode(toMap());
}
