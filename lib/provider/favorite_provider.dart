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
  FavoriteNotifier() : super({});

  String? _currentUserId;

  // Load favorites for specific user
  Future<void> loadFavoritesForUser(String userId) async {
    _currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    final favoriteString = prefs.getString('favorites_$userId');

    if (favoriteString != null) {
      try {
        final Map<String, dynamic> favoriteMap = jsonDecode(favoriteString);
        final favorites = favoriteMap.map(
          (key, value) => MapEntry(key, Favorite.fromJson(value)),
        );
        state = favorites;
      } catch (e) {
        print('Error loading favorites for user $userId: $e');
        state = {};
      }
    } else {
      state = {};
    }
  }

  // Save favorites for current user
  Future<void> _saveFavorites() async {
    if (_currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final favoriteString = jsonEncode(state);
    await prefs.setString('favorites_$_currentUserId', favoriteString);
  }

  // Clear favorites for current user
  Future<void> clearFavoritesForUser() async {
    if (_currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favorites_$_currentUserId');
    state = {};
  }

  // Clear all favorites data (chỉ dùng khi cần thiết)
  Future<void> clearAllFavoritesData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    // Remove all favorites-related keys
    for (String key in keys) {
      if (key.startsWith('favorites_')) {
        await prefs.remove(key);
      }
    }

    _currentUserId = null;
    state = {};
  }

  // Reset favorites state khi đăng xuất (chỉ clear state, không xóa SharedPreferences)
  void resetFavoriteState() {
    _currentUserId = null;
    state = {};
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
    if (_currentUserId == null) {
      print('Warning: No user logged in, cannot add to favorites');
      return;
    }

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
    _saveFavorites();
  }

  void removeFavoriteItem(String productId) {
    if (_currentUserId == null) return;

    state.remove(productId);
    state = {...state};
    _saveFavorites();
  }

  Map<String, Favorite> get getFavoriteItems => state;

  String? get currentUserId => _currentUserId;
}
