import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zing_whitelabel_revamp/constants.dart';

class ApiClient {
  // static const String baseUrl = "https://vendor.zingmyorder.com/restaurantapp/public/api";

  /// POST request
  Future<Map<String, dynamic>?> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Constants.baseUrl}/$endpoint');
    final headers = {
      'Content-Type': 'application/json',
    };

    print('POST $url');
    print('Request Headers: $headers');
    print('Request Body: $body');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        print("Request failed with status: ${response.statusCode}");
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('HTTP POST Error: $e');
      return null;
    }
  }

  /// GET request
  Future<Map<String, dynamic>?> get(String endpoint) async {
    final url = Uri.parse('${Constants.baseUrl}/$endpoint');
    final headers = {
      'Content-Type': 'application/json',
    };

    print('GET $url');
    print('Request Headers: $headers');

    try {
      final response = await http.get(
        url,
        headers: headers,
      );

      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        print("GET request failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print('HTTP GET Error: $e');
      return null;
    }
  }
}

