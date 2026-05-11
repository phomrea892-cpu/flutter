// lib/service/parse_books.dart
import 'dart:convert';
import '../models/book.dart';

List<Book> parseBooks(String responseBody) {
  final data = json.decode(responseBody);

  // ✅ DummyJSON wraps products in { "products": [...] }
  final List<dynamic> list = data is Map
      ? (data['products'] ?? data['books'] ?? [])
      : data;

  return list
      .map((item) {
        try {
          return Book.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          return null;
        }
      })
      .whereType<Book>() // ✅ removes any nulls safely
      .toList();
}