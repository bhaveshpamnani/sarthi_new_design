import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:shop/route/screen_export.dart';

class AuthService {
  final String baseURL = "http://localhost:3000";

  /// Sign-up
  Future<String> signup(String name, String email, String phone, String password,BuildContext context,) async {
    try {
      final response = await http.post(
        Uri.parse("$baseURL/api/users/signup"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );
      print("Sign Up Called");
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        final String userId = data['user']['_id']; // Adjust key as per your API response
        await prefs.setString('userId', userId);
        Navigator.pushNamed(context, logInScreenRoute);
        return 'User signed up successfully';

      } else {
        return jsonDecode(response.body)['message'] ?? 'An error occurred during sign-up';
      }
    } catch (error) {
      return 'Error: Unable to connect to the server';
    }
  }

  /// Login
  Future<void> signInUser({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseURL/api/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final String token = data['token'];
        // Save token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        prefs.getString('userId');
      } else {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Login failed';
        _showSnackBar(context, errorMsg);
      }
    } catch (error) {
      _showSnackBar(context, "An error occurred. Please try again.");
    }
  }

  /// Helper function to show SnackBar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Get User Profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      return null; // Token is missing; user needs to log in again
    }

    try {
      final response = await http.get(
        Uri.parse('$baseURL/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['user'];
      } else {
        return null;
      }
    } catch (error) {
      return null; // Error fetching user profile
    }
  }

  /// Update User Profile
  Future<String> updateUserProfile(
      String userId, String name, String email, String phone, List<Map<String, dynamic>> address) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
      return 'Unauthorized';
    }

    try {
      final response = await http.put(
        Uri.parse('$baseURL/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
        }),
      );

      if (response.statusCode == 200) {
        return 'Profile updated successfully';
      } else {
        return jsonDecode(response.body)['message'] ?? 'Failed to update profile';
      }
    } catch (error) {
      return 'Error: Unable to update profile';
    }
  }
}
