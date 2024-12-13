import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_uas/model.dart';

class ApiService {
  static const String baseUrl =
      "https://localhost:3000"; // Ganti dengan URL server Anda

  // Fungsi untuk mengambil data
  var client = http.Client();
  Future<List<User>?> getUsers() async {
    var uri = Uri.parse('http://localhost:3000/users');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      return userFromJson(response.body);
    } else {
      return null;
    }
  }

  Future<List<News>?> getNews() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/news'));
      if (response.statusCode == 200) {
        final List<dynamic> newsList = jsonDecode(response.body);
        return newsList.map((data) => News.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Fungsi untuk login
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('https://localhost:3000/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Login failed");
    }
  }

  // Fungsi untuk menambahkan berita
  static Future<Map<String, dynamic>> addNews(Map<String, String> news) async {
    final response = await http.post(
      Uri.parse('https://localhost:3000/news'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(news),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add news");
    }
  }

  // Fungsi untuk menghapus berita
  static Future<void> deleteNews(String id) async {
    final response =
        await http.delete(Uri.parse('https://localhost:3000/news/$id'));
    if (response.statusCode != 200) {
      throw Exception("Failed to delete news");
    }
  }
}
