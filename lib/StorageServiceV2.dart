import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageServiceV2 {
  static const String _keyHomeData = 'home_data';

  static const String _keyThemeColor = 'theme_color_hex';
  static const String _keyBgColor = 'bg_color_hex';

  static Future<void> saveThemeColorHex(String hexColor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeColor, hexColor);
  }

  static Future<void> saveBgColorHex(String bgColor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBgColor, bgColor);
  }

  static Future<String?> getBgColorHex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBgColor);
  }

  static Future<String?> getThemeColorHex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeColor);
  }

  /// Save full JSON response from home API
  static Future<void> saveHomeData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHomeData, jsonEncode(data));
  }

  /// Get full cached home data
  static Future<Map<String, dynamic>?> getHomeData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyHomeData);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  /// Internal helpers
  static Future<List<dynamic>> _getListByKey(String key) async {
    final data = await getHomeData();
    return data?[key] is List ? List<dynamic>.from(data![key]) : [];
  }

  static Future<Map<String, dynamic>?> _getMapByKey(String key) async {
    final data = await getHomeData();
    return data?[key] is Map ? Map<String, dynamic>.from(data![key]) : null;
  }

  static Future<String?> _getStringByKey(String key) async {
    final data = await getHomeData();
    return data?[key] is String ? data![key] : null;
  }

  // ─────────────────────── Specific Getters ───────────────────────

  static Future<List<dynamic>> getSliderImages() => _getListByKey('slider_images');

  static Future<Map<String, dynamic>?> getPoints() => _getMapByKey('points');

  static Future<List<dynamic>> getPopularDishes() => _getListByKey('popular_dishes');

  static Future<List<dynamic>> getFeaturedImages() => _getListByKey('featured_images');

  static Future<List<dynamic>> getGalleryImages() => _getListByKey('gallery');

  static Future<String?> getOrderNowUrl() => _getStringByKey('order_now');

  static Future<List<dynamic>> getFavoriteOrders() => _getListByKey('favoite_orders');

  static Future<List<dynamic>> getRecentOrders() => _getListByKey('recent_orders');

  /// Optional: Clear all cached data
  static Future<void> clearHomeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHomeData);
  }
}
