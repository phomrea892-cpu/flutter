// lib/service/parse_books.dart
import 'dart:convert';
import '../models/product.dart';

List<Product> parseBooks(String responseBody) {
  final data = json.decode(responseBody);

  final List<dynamic> list = data is Map
      ? (data['products'] ?? data['books'] ?? [])
      : data;

  return list
      .map((item) {
        try {
          return Product.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          return null;
        }
      })
      .whereType<Product>()
      .toList();
}