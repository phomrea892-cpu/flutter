// lib/service/book_service.dart
import 'package:http/http.dart' as http;
import '../models/book.dart';
import 'parse_books.dart';

class BookService {
  static const String _baseUrl = 'https://dummyjson.com/products';

  // ✅ Removed: get price => null; (was causing issues)

  Future<List<Book>> fetchBooks(
    String query,
    List<Book> Function(String responseBody) parser,
  ) async {
    try {
      final q = query.trim();
      final uri = q.isEmpty
          ? Uri.parse('$_baseUrl?limit=20')
          : Uri.parse(
              '$_baseUrl/search?q=${Uri.encodeComponent(q)}&limit=20');
      final response = await http.get(uri);
      if (response.statusCode == 200) return parser(response.body);
      throw Exception('fetchBooks failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('fetchBooks error: $e');
    }
  }

  Future<List<Book>> readapi() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?limit=20'),
      );
      if (response.statusCode == 200) return parseBooks(response.body);
      throw Exception('readapi failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('readapi error: $e');
    }
  }

  // ✅ Search API directly
  Future<List<Book>> searchApi(String query) async {
    try {
      final uri = Uri.parse(
          '$_baseUrl/search?q=${Uri.encodeComponent(query.trim())}&limit=20');
      final response = await http.get(uri);
      if (response.statusCode == 200) return parseBooks(response.body);
      throw Exception('searchApi failed: ${response.statusCode}');
    } catch (e) {
      throw Exception('searchApi error: $e');
    }
  }
}