// lib/service/book_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class BookService {
  static const String _baseUrl =
      'https://makeup-api.herokuapp.com/api/v1/products.json';

  // ── Load home products (Maybelline) ───────────────────────────
  Future<List<Product>> readApi() async {
    final uri = Uri.parse('$_baseUrl?brand=maybelline&limit=20');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('readApi failed: ${response.statusCode}');
  }

  // ── Search by product_type across ALL brands ──────────────────
  // Used when a category chip is tapped (e.g. "lipstick", "mascara").
  Future<List<Product>> searchByType(String productType) async {
    final q = productType.trim();
    if (q.isEmpty) return [];

    final uri = Uri.parse(
        '$_baseUrl?product_type=${Uri.encodeComponent(q)}');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('searchByType failed: ${response.statusCode}');
  }

  // ── Fetch all products for client-side name search ────────────
  // The Makeup API has no free-text name search endpoint, so we
  // load all products and filter by name in the provider.
  Future<List<Product>> fetchAll() async {
    final uri = Uri.parse(_baseUrl);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    }
    throw Exception('fetchAll failed: ${response.statusCode}');
  }

  // ── Legacy generic fetch (kept for compatibility) ─────────────
  Future<List<Product>> fetchBooks(
    String query,
    List<Product> Function(String responseBody) parser,
  ) async {
    final q = query.trim();
    final uri = q.isEmpty
        ? Uri.parse('$_baseUrl?brand=maybelline')
        : Uri.parse(
            '$_baseUrl?product_type=${Uri.encodeComponent(q)}');
    final response = await http.get(uri);
    if (response.statusCode == 200) return parser(response.body);
    throw Exception('fetchBooks failed: ${response.statusCode}');
  }
}