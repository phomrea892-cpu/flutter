// lib/state_manegement/search_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/provider/product_provider.dart';
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
  Timer? _debounce;
  bool _hasSearched = false;

  static const List<String> _categories = [
    'lipstick',
    'foundation',
    'blush',
    'bronzer',
    'mascara',
    'eyeshadow',
    'eyeliner',
    'lip_liner',
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ── Text field search: debounced, searches by name ─────────────
  void _onTextChanged(String value, ProductProvider provider) {
    setState(() {}); // update clear-icon visibility
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final q = value.trim();
      if (q.isEmpty) {
        // If a category is still selected, fall back to type search
        if (_selectedCategory.isNotEmpty) {
          setState(() => _hasSearched = true);
          provider.searchByType(_selectedCategory);
        } else {
          setState(() => _hasSearched = false);
          provider.clearSearch();
        }
      } else {
        // Free-text typed → name/brand/type search, ignore chip
        setState(() {
          _hasSearched = true;
          _selectedCategory = ''; // deselect chip when typing
        });
        provider.searchByName(q);
      }
    });
  }

  // ── Category chip tap: searches by product_type via API ────────
  void _onCategoryTap(String cat, ProductProvider provider) {
    _debounce?.cancel();
    final newCat = _selectedCategory == cat ? '' : cat;
    setState(() {
      _selectedCategory = newCat;
      _searchController.clear(); // clear text when chip tapped
    });

    if (newCat.isEmpty) {
      setState(() => _hasSearched = false);
      provider.clearSearch();
    } else {
      setState(() => _hasSearched = true);
      provider.searchByType(newCat);
    }
  }

  // ── Clear everything ───────────────────────────────────────────
  void _clearAll(ProductProvider provider) {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _selectedCategory = '';
    });
    provider.clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<ProductProvider>();
    final results = provider.searchResults;
    final isLoading = provider.isSearching;

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
          // ── Search field ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search products by name, brand, or type...',
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF6B4EFF)),
                suffixIcon: _searchController.text.isNotEmpty ||
                        _selectedCategory.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => _clearAll(provider),
                      )
                    : null,
                filled: true,
                fillColor: isDark
                    ? Colors.grey[800]
                    : const Color(0xFFF2F2F7),
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
                  borderSide: const BorderSide(
                      color: Color(0xFF6B4EFF), width: 2),
                ),
              ),
              onChanged: (v) => _onTextChanged(v, provider),
              onSubmitted: (v) {
                // Pressing keyboard search button triggers immediately
                _debounce?.cancel();
                final q = v.trim();
                if (q.isNotEmpty) {
                  setState(() {
                    _hasSearched = true;
                    _selectedCategory = '';
                  });
                  provider.searchByName(q);
                }
              },
            ),
          ),

          // ── Category chips ─────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                final label = cat
                    .replaceAll('_', ' ')
                    .split(' ')
                    .map((w) => w[0].toUpperCase() + w.substring(1))
                    .join(' ');
                return GestureDetector(
                  onTap: () => _onCategoryTap(cat, provider),
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
                      label,
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

          // ── Results count ──────────────────────────────────────
          if (_hasSearched && !isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${results.length} result${results.length != 1 ? 's' : ''} found',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
            ),

          // ── Body ───────────────────────────────────────────────
          Expanded(
            child: isLoading
                ? _buildShimmer(isDark)
                : !_hasSearched
                    ? _buildPrompt()
                    : results.isEmpty
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
                            itemCount: results.length,
                            itemBuilder: (context, index) =>
                                _buildProductCard(results[index], isDark),
                          ),
          ),
        ],
      ),
    );
  }

  // ── Image URL ─────────────────────────────────────────────────
  String _getImageUrl(Product product) {
    final candidates = [
      product.imageLink,
      product.apiFeaturedImage,
      product.coverUrl,
    ];
    for (final url in candidates) {
      if (url.isNotEmpty) {
        String fixed = url.trim();
        if (fixed.startsWith('http://')) {
          fixed = fixed.replaceFirst('http://', 'https://');
        }
        if (!fixed.startsWith('http')) fixed = 'https://$fixed';
        return fixed;
      }
    }
    return '';
  }

  Widget _buildCachedImage(Product product, bool isDark) {
    final imageUrl = _getImageUrl(product);
    if (imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        color: const Color(0xFF6B4EFF).withOpacity(0.08),
        child: const Icon(Icons.image_not_supported,
            color: Color(0xFF6B4EFF), size: 40),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(color: Colors.white),
      ),
      errorWidget: (_, __, ___) => Container(
        color: const Color(0xFF6B4EFF).withOpacity(0.08),
        child: const Icon(Icons.image_not_supported,
            color: Color(0xFF6B4EFF), size: 40),
      ),
    );
  }

  Widget _buildProductCard(Product product, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DetailScreen(product: product)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _buildCachedImage(product, isDark),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color:
                    isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'USD ${product.priceDouble.toStringAsFixed(2)}',
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

  Widget _buildPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded,
              size: 72,
              color: const Color(0xFF6B4EFF).withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'Search or pick a category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Type a product name, brand, or tap a chip above',
            style:
                TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

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
          const Text(
            'Try a different name or select a category chip',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

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