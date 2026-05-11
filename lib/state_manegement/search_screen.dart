// lib/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/book.dart';
import 'package:flutter_application_1/provider/book_provider.dart';
import 'package:flutter_application_1/state_manegement/detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query, BookProvider provider) {
    if (query.trim().isEmpty) {
      provider.searchBooks('');
    } else {
      provider.searchBooks(query.trim());
    }
  }

  List<Book> _getDisplayBooks(BookProvider provider) {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      final allBooks = [
        ...provider.featuredBooks,
        ...provider.trendingBooks,
      ];
      if (_selectedCategory.isNotEmpty) {
        return allBooks
            .where((book) =>
                book.category.toLowerCase() ==
                _selectedCategory.toLowerCase())
            .toList();
      }
      return allBooks;
    }

    if (_selectedCategory.isNotEmpty) {
      return provider.searchResults
          .where((book) =>
              book.category.toLowerCase() ==
              _selectedCategory.toLowerCase())
          .toList();
    }
    return provider.searchResults;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<BookProvider>();

    final displayBooks = _getDisplayBooks(provider);
    final isLoading = provider.isSearching ||
        provider.isLoadingFeatured ||
        provider.isLoadingTrending;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Column(
        children: [

          // ─── Search Bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF6B4EFF)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          provider.searchBooks('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor:
                    isDark ? Colors.grey[800] : const Color(0xFFF2F2F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFF6B4EFF), width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {});
                _onSearchChanged(value, provider);
              },
            ),
          ),

          // ─── Category Filter Chips ───────────────────────────────
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              
              itemBuilder: (context, index) {
                var _categories = ['fastion', 'modern', 'Sports', 'Education', 'Art', 'Blog'];
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(
                      () => _selectedCategory = isSelected ? '' : cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6B4EFF)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6B4EFF)
                            : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ─── Result Count ────────────────────────────────────────
          if (_searchController.text.isNotEmpty && !isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${displayBooks.length} result${displayBooks.length != 1 ? 's' : ''} found',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          // ─── Results Grid ────────────────────────────────────────
          Expanded(
            child: isLoading
                ? _buildShimmer(isDark)
                : displayBooks.isEmpty
                    ? _buildNoResults()
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: displayBooks.length,
                        itemBuilder: (context, index) =>
                            _buildBookCard(displayBooks[index], isDark),
                      ),
          ),
        ],
      ),
    );
  }

  // ─── Book Card ───────────────────────────────────────────────────
  Widget _buildBookCard(Book book, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(book: book)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: book.coverUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor:
                      isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  highlightColor:
                      isDark ? Colors.grey[700]! : Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFF6B4EFF).withOpacity(0.08),
                  child: const Icon(Icons.image_not_supported,
                      color: Color(0xFF6B4EFF), size: 40),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          // ✅ Fixed: price is non-nullable
          Text(
            'USD ${book.price.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B4EFF),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ─── No Results ──────────────────────────────────────────────────
  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.find_in_page_outlined,
              size: 80,
              color: const Color(0xFF6B4EFF).withOpacity(0.4)),
          const SizedBox(height: 16),
          const Text('No products found',
              style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Try a different search term',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ─── Shimmer ─────────────────────────────────────────────────────
  Widget _buildShimmer(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
                height: 12,
                width: 100,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 6),
            Container(
                height: 12,
                width: 60,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6))),
          ],
        ),
      ),
    );
  }
}