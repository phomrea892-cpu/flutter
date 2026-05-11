import 'dart:convert' show json;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/book.dart';
import 'package:flutter_application_1/service/book_service.dart';

mixin GridStyle on ChangeNotifier {
  bool gridStyle = false;

  void toggleGridStyle() {
    gridStyle = !gridStyle;
    notifyListeners();
  }
}

class BookProvider extends ChangeNotifier with GridStyle {
  final BookService _bookService = BookService();

  List<Book> featuredBooks = [];
  List<Book> trendingBooks = [];
  List<Book> searchResults = [];
  List<Book> savedBooks = [];

  bool isLoadingFeatured = false;
  bool isLoadingTrending = false;
  bool isSearching = false;
  String error = '';

  // ── Load Home Books ───────────────────────────────────────────────
  Future<void> loadHomeBooks() async {
    error = '';
    isLoadingFeatured = true;
    isLoadingTrending = true;
    notifyListeners();

    try {
      final books = await _bookService.readapi();
      featuredBooks = books.take(6).toList();
      trendingBooks = books.skip(6).take(6).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingFeatured = false;
      isLoadingTrending = false;
      notifyListeners();
    }
  }

  // ── Search Books ──────────────────────────────────────────────────
  Future<void> searchBooks(String query) async {
  if (query.trim().isEmpty) {
    searchResults = [];
    notifyListeners();
    return;
  }

  isSearching = true;
  error = '';
  notifyListeners();

  try {
    // ✅ Search locally first
    final allBooks = [...featuredBooks, ...trendingBooks];
    final localResults = allBooks
        .where((book) =>
            book.title.toLowerCase().contains(query.toLowerCase()) ||
            book.category.toLowerCase().contains(query.toLowerCase()) ||
            book.author.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (localResults.isNotEmpty) {
      searchResults = localResults;
    } else {
      // ✅ Fallback to API search
      searchResults = await _bookService.searchApi(query);
    }
  } catch (e) {
    error = e.toString();
    searchResults = [];
  } finally {
    isSearching = false;
    notifyListeners();
  }
}
  // ── ✅ FIXED: isSaved — returns bool ─────────────────────────────
  bool isSaved(String bookId) {
    if (bookId.isEmpty) return false;
    return savedBooks.any((book) => book.id == bookId);
  }

  // ── ✅ FIXED: toggleSave — saves or removes book ─────────────────
  void toggleSave(Book book) {
    if (isSaved(book.id)) {
      savedBooks.removeWhere((b) => b.id == book.id);
    } else {
      savedBooks.add(book);
    }
    notifyListeners();
  }

  // ── ✅ FIXED: toggleSaved — alias using id only ──────────────────
  void toggleSaved(String bookId) {
    final exists = savedBooks.any((b) => b.id == bookId);
    if (exists) {
      savedBooks.removeWhere((b) => b.id == bookId);
      notifyListeners();
    }
  }
}