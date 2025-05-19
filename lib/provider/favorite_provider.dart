import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/favorite.dart';

final favoriteProvider =
    StateNotifierProvider<FavoriteNotifier, Map<String, Favorite>>((ref) {
      return FavoriteNotifier();
    });

class FavoriteNotifier extends StateNotifier<Map<String, Favorite>> {
  FavoriteNotifier() : super({}) {
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteString = prefs.getString('favorite');

    if (favoriteString != null) {
      final Map<String, dynamic> favoriteMap = jsonDecode(favoriteString);

      final favorites = favoriteMap.map(
        (key, value) => MapEntry(key, Favorite.fromJson(value)),
      );

      state = favorites;
    }
  }

  Future<void> _saveFavorite() async {
    final prefs = await SharedPreferences.getInstance();

    final favoriteString = jsonEncode(state);

    await prefs.setString('favorite', favoriteString);
  }

  void addProductToFavorite({
    required String productName,
    required int productPrice,
    required String category,
    required List<String> image,
    required String vendorId,
    required int productQuantity,
    required int quantity,
    required String productId,
    required String description,
    required String fullName,
  }) {
    state[productId] = Favorite(
      productName: productName,
      productPrice: productPrice,
      category: category,
      image: image,
      vendorId: vendorId,
      productQuantity: productQuantity,
      quantity: quantity,
      productId: productId,
      description: description,
      fullName: fullName,
    );

    state = {...state};
    _saveFavorite();
  }

  void removeFavoriteItem(String productId) {
    state.remove(productId);
    state = {...state};
    _saveFavorite();
  }

  Map<String, Favorite> get getFavoriteItems => state;
}
