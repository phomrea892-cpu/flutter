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

  // Cache of all products for client-side name search
  List<Product> _allProducts = [];

  bool isLoadingFeatured = false;
  bool isLoadingTrending = false;
  bool isSearching = false;
  String error = '';

  // ── Home ───────────────────────────────────────────────────────
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

  // ── Search by free-text name (client-side filter) ──────────────
  // The Makeup API has no name search endpoint, so we fetch all
  // products once, cache them, then filter locally by name.
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
      // Load full catalogue once and cache
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

  // ── Search by product_type via API (used by category chips) ────
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

  // ── Legacy searchBooks (kept so nothing else breaks) ──────────
  Future<void> searchBooks(String query) => searchByName(query);

  // ── Clear search results ───────────────────────────────────────
  void clearSearch() {
    searchResults = [];
    isSearching = false;
    notifyListeners();
  }

  // ── Saved / Favourites ─────────────────────────────────────────
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