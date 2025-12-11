import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _keyToken = 'auth_token';
  static const _keyUser = 'auth_user';
  static const _keyRestaurant = 'restaurant_data';
  static const _keyCategories = 'restaurant_categories';
  static const _keyMenuItems = 'restaurant_menu_items';
  static const _keyGroups = 'restaurant_groups';
  static const _keyHomeSliderImages = 'home_slider_images';
  static const _keyFeaturedFood = 'home_featured_food';
  static const _keyRestaurantInfo = 'restaurant_info';
  static const _keyAppInfo = 'app_info';
  static const _keyFCMToken = 'fcm_token';
  static const _keyUserPoints = 'user_points';
  static const _keyIsGroups = 'is_subcategory';
  static const _keyLocations = "locations";
  static const _keyColors = "app_colors";

  /// Save token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  /// Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Save FCM token
  static Future<void> saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFCMToken, token);
  }

  /// Get FCM token
  static Future<String?> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFCMToken);
  }

  /// Save user as JSON string
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user));
  }

  /// Get user as map
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUser);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final user = prefs.getString(_keyUser);
    return token != null && token.isNotEmpty && user != null && user.isNotEmpty;
  }

  /// Clear all saved auth data
  static Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  static Future<void> saveRestaurantData(Map<String, dynamic> restaurant) async {
    final prefs = await SharedPreferences.getInstance();

    // Save full restaurant object
    await prefs.setString(_keyRestaurant, jsonEncode(restaurant));

    // Save categories
    final categories = restaurant['category'] ?? [];
    await prefs.setString(_keyCategories, jsonEncode(categories));

    // Extract and flatten all menu items from categories
    final allMenus = <dynamic>[];
    for (final category in categories) {
      if (category['menu'] != null && category['menu'] is List) {
        allMenus.addAll(category['menu']);
      }
    }

    // Save flattened menu list
    await prefs.setString(_keyMenuItems, jsonEncode(allMenus));

    // Save groups if available
    if (restaurant.containsKey('group')) {
      await prefs.setString(_keyGroups, jsonEncode(restaurant['group']));
    }

    if (restaurant.containsKey('is_subcategory')) {
      await prefs.setString(_keyIsGroups, restaurant['is_subcategory']);
    }
  }

  static Future<String?> getIsGroup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyIsGroups);
  }

  static Future<Map<String, dynamic>?> getRestaurant() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyRestaurant);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  static Future<List<dynamic>> getCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyCategories);
    return jsonString == null ? [] : jsonDecode(jsonString);
  }

  static Future<List<dynamic>> getMenuItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyMenuItems);
    return jsonString == null ? [] : jsonDecode(jsonString);
  }

  static Future<List<dynamic>> getGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyGroups);
    return jsonString == null ? [] : jsonDecode(jsonString);
  }

  /// Save Home tab data: featured food and slider images
  static Future<void> saveHomeData(Map<String, dynamic> appData) async {
    final prefs = await SharedPreferences.getInstance();

    // Save slider images
    if (appData['slider_images'] != null) {
      await prefs.setString(_keyHomeSliderImages, jsonEncode(appData['slider_images']));
    }

    // Save featured food
    if (appData['featured_food'] != null) {
      await prefs.setString(_keyFeaturedFood, jsonEncode(appData['featured_food']));
    }
  }

  /// Get slider images
  static Future<List<dynamic>> getSliderImages() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyHomeSliderImages);
    return jsonString == null ? [] : jsonDecode(jsonString);
  }

  /// Get featured food
  static Future<List<dynamic>> getFeaturedFood() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyFeaturedFood);
    return jsonString == null ? [] : jsonDecode(jsonString);
  }

  /// Save restaurant info (excluding logo)
  static Future<void> saveRestaurantInfo(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    final cleanedData = Map<String, dynamic>.from(data);
    if (cleanedData['restaurant'] is Map) {
      await prefs.setString(_keyRestaurantInfo, jsonEncode(cleanedData['restaurant']));
    }

    // Save app info separately
    if (cleanedData['app'] is Map) {
      await prefs.setString(_keyAppInfo, jsonEncode(cleanedData['app']));

      // Save locations separately if exists
      final appData = cleanedData['app'] as Map<String, dynamic>;
      if (appData['locations'] is List) {
        await prefs.setString(_keyLocations, jsonEncode(appData['locations']));
      }

      if (appData['colors'] is Map) {
        await prefs.setString(_keyColors, jsonEncode(appData['colors']));
      }
    }
  }

  /// Get stored color map
  static Future<Map<String, dynamic>?> getAppColors() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyColors);

    if (jsonString == null) return null;

    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyLocations);
    if (jsonString == null) return [];
    return jsonDecode(jsonString) as List<dynamic>;
  }

  /// Get restaurant info
  static Future<Map<String, dynamic>?> getRestaurantInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyRestaurantInfo);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  /// Get app info
  static Future<Map<String, dynamic>?> getAppInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyAppInfo);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  static Future<void> saveUserPoints(String points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserPoints, points);
  }

  static Future<String?> getUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserPoints);
  }
}
