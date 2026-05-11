import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import "package:flutter_application_1/provider/book_provider.dart";
import 'package:flutter_application_1/provider/theme_provider.dart';
import 'package:flutter_application_1/state_manegement/detail_screen.dart';
import 'package:flutter_application_1/widgets/book_cart.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().loadHomeBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookProvider = context.watch<BookProvider>();
    final bool gridStyle = bookProvider.gridStyle;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      floatingActionButton: _buildFloating(),
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront, color: Color(0xFF6B4EFF)),
            SizedBox(width: 8),
            Text(
              'Skin Store',
              style: TextStyle(
                color: Colors.brown,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: themeProvider.toggleTheme,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<BookProvider>().toggleGridStyle();
            },
            icon: Icon(gridStyle ? Icons.list : Icons.grid_view),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<BookProvider>(
        builder: (context, provider, _) {
          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: Color(0xFF6B4EFF)),
                  const SizedBox(height: 16),
                  Text('Failed to load', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: provider.loadHomeBooks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final allBooks = [
            ...provider.featuredBooks,
            ...provider.trendingBooks,
          ];
          final isLoading =
              provider.isLoadingFeatured || provider.isLoadingTrending;

          return RefreshIndicator(
            onRefresh: provider.loadHomeBooks,
            color: const Color(0xFF6B4EFF),
            child: isLoading
                ? _buildShimmer(isDark, gridStyle)
                : gridStyle
                    ? _buildGridView(allBooks, isDark)
                    : _buildListView(allBooks, isDark),
          );
        },
      ),
    );
  }

  // ── 2-column Grid (matches screenshot) ─────────────────────────────────────
  Widget _buildGridView(List<dynamic> books, bool isDark) {
    return GridView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return _buildProductCard(books[index], isDark);
      },
    );
  }

  // ── List View ───────────────────────────────────────────────────────────────
  Widget _buildListView(List<dynamic> books, bool isDark) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return BookCard(book: books[index], isHorizontal: true);
      },
    );
  }

  // ── Single product card (image + centered title + price) ───────────────────
  Widget _buildProductCard(dynamic book, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailScreen(book: book)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product image
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: book.coverUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
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
          // Title — centered
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
          // Price — centered
          Text(
            'USD ${book.price?.toStringAsFixed(2) ?? "0.00"}',
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

  // ── Shimmer skeleton ────────────────────────────────────────────────────────
  Widget _buildShimmer(bool isDark, bool isGrid) {
    if (isGrid) {
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
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 12,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Container(
          height: 110,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // ── Scroll-to-top FAB ───────────────────────────────────────────────────────
  Widget _buildFloating() {
    return FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: () {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      backgroundColor: const Color(0xFF6B4EFF),
      child: const Icon(Icons.arrow_upward, color: Colors.white),
    );
  }
}