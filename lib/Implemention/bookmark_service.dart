
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookmarkService {
  final String baseUrl = "http://localhost:3000/api/wishlist";

  Future<Map<String, dynamic>> toggleBookmark(String userId, String productId) async {
    final url = '$baseUrl/toggle';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "userId": userId,
          "productId": productId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          "success": true,
          "message": responseData['message'],
          "isInWishlist": responseData['wishlist']['items']
              .any((item) => item['product'] == productId),
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          "success": false,
          "message": errorData['message'],
        };
      }
    } catch (error) {
      print("Error toggling wishlist: $error");
      return {
        "success": false,
        "message": "An error occurred",
      };
    }
  }

  Future<Map<String, dynamic>> getBookmarkStatus(String userId, String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status/$userId/$productId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          "success": true,
          "isInWishlist": data['isInWishlist'] ?? false,
        };
      } else {
        return {
          "success": false,
          "message": "Failed to fetch wishlist status",
        };
      }
    } catch (error) {
      print("Error in getWishlistStatus: $error");
      return {
        "success": false,
        "message": "Error fetching wishlist status",
      };
    }
  }

  Future<Map<String, dynamic>> getUserBookmark(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product-by-user/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          "success": true,
          "wishlist": data['wishlist'],
        };
      } else {
        return {
          "success": false,
          "message": "Failed to load wishlist",
        };
      }
    } catch (error) {
      return {
        "success": false,
        "message": "An error occurred while fetching the wishlist",
      };
    }
  }
}
