import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<List<dynamic>> fetchCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories/getAll'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['categories'];
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<dynamic>> fetchProductsByCategory(String categoryId) async {
    final response = await http.get(Uri.parse('$baseUrl/products/categoryProduct/$categoryId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['products'];
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load products');
    }
  }
}
