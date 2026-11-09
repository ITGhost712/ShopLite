import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class ShopStorage {
  static const _cartKey = 'shoplite_cart';
  static const _favoritesKey = 'shoplite_favorites';
  static const _lightModeKey = 'shoplite_light_mode';

  Future<bool> loadLightMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_lightModeKey) ?? false;
  }

  Future<void> saveLightMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lightModeKey, enabled);
  }

  Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cartKey);
    if (raw == null) return [];
    final items = jsonDecode(raw) as List<dynamic>;
    return items
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_favoritesKey);
    if (raw == null) return [];
    final items = jsonDecode(raw) as List<dynamic>;
    return items
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCart(List<CartItem> cart) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cartKey,
      jsonEncode(cart.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> saveFavorites(List<Product> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _favoritesKey,
      jsonEncode(favorites.map((product) => product.toJson()).toList()),
    );
  }
}
