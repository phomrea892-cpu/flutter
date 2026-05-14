// lib/provider/product_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/service/book_service.dart';

mixin GridStyle on ChangeNotifier {
  bool gridStyle = true;
  void toggleGridStyle() {
    gridStyle = !gridStyle;
    notifyListeners();
  }
}
class ProductProvider extends ChangeNotifier with GridStyle {
  final BookService _bookService = BookService();
  List<Product> featuredBooks = [];
  List<Product> trendingBooks = [];
  List<Product> searchResults = [];
  List<Product> savedBooks = [];
  List<Product> _allProducts = [];

  bool isLoadingFeatured = false;
  bool isLoadingTrending = false;
  bool isSearching = false;
  String error = '';
  Future<void> loadHomeBooks() async {
    error = '';
    isLoadingFeatured = true;
    isLoadingTrending = true;
    notifyListeners();

    try {
      final products = await _bookService.readApi();
      featuredBooks = products.take(12).toList();
      trendingBooks = products.skip(12).take(20).toList();
    } catch (e) {
      error = e.toString();
      debugPrint('❌ Error loading products: $e');
    } finally {
      isLoadingFeatured = false;
      isLoadingTrending = false;
      notifyListeners();
    }
  }
  Future<void> searchByName(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      clearSearch();
      return;
    }

    isSearching = true;
    error = '';
    notifyListeners();

    try {
      if (_allProducts.isEmpty) {
        _allProducts = await _bookService.fetchAll();
      }
      searchResults = _allProducts
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.brand.toLowerCase().contains(q) ||
              p.productType.toLowerCase().contains(q))
          .toList();
    } catch (e) {
      error = e.toString();
      searchResults = [];
      debugPrint('❌ Name search error: $e');
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }
  Future<void> searchByType(String productType) async {
    final q = productType.trim();
    if (q.isEmpty) {
      clearSearch();
      return;
    }

    isSearching = true;
    error = '';
    notifyListeners();

    try {
      searchResults = await _bookService.searchByType(q);
    } catch (e) {
      error = e.toString();
      searchResults = [];
      debugPrint('❌ Type search error: $e');
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }
  Future<void> searchBooks(String query) => searchByName(query);
  void clearSearch() {
    searchResults = [];
    isSearching = false;
    notifyListeners();
  }
  bool isSaved(String productId) =>
      savedBooks.any((p) => p.id == productId);

  void toggleSave(Product product) {
    if (isSaved(product.id)) {
      savedBooks.removeWhere((p) => p.id == product.id);
    } else {
      savedBooks.add(product);
    }
    notifyListeners();
  }
}