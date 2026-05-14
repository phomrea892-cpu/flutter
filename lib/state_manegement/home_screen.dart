// lib/state_management/home_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/provider/product_provider.dart';
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
  final ScrollController _scrollController = ScrollController();

  String _getImageUrl(Product product) {
    final candidates = [
      product.coverUrl,
      product.imageLink,
      product.apiFeaturedImage,
    ];
    for (final url in candidates) {
      if (url.trim().isNotEmpty) {
        String fixed = url.trim();
        if (fixed.startsWith('http://')) {
          fixed = fixed.replaceFirst('http://', 'https://');
        }
        return fixed;
      }
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadHomeBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<ProductProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      floatingActionButton: _buildFloatingButton(),
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront, color: Color(0xFF6B4EFF)),
            SizedBox(width: 8),
            Text(
              'HEALTHCARE Store',
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
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(isDark),
              ),
            ),
          ),
          IconButton(
            onPressed: provider.toggleGridStyle,
            icon: Icon(provider.gridStyle ? Icons.list : Icons.grid_view),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, prov, _) {
          if (prov.error.isNotEmpty) {
            return _buildErrorState(theme, prov);
          }

          final allProducts = [...prov.featuredBooks, ...prov.trendingBooks];
          final isLoading = prov.isLoadingFeatured || prov.isLoadingTrending;

          return RefreshIndicator(
            onRefresh: prov.loadHomeBooks,
            color: const Color(0xFF6B4EFF),
            child: isLoading
                ? _buildShimmer(isDark, provider.gridStyle)
                : provider.gridStyle
                    ? _buildGridView(allProducts, isDark)
                    : _buildListView(allProducts),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ProductProvider prov) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFF6B4EFF)),
          const SizedBox(height: 8),
          Text('Failed to load products', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          ElevatedButton(
            onPressed: prov.loadHomeBooks,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Product> products, bool isDark) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 4,
        mainAxisSpacing: 3,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) =>
          _buildProductCard(products[index], isDark),
    );
  }

  Widget _buildListView(List<Product> products) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) =>
          BookCard(book: products[index], isHorizontal: true),
    );
  }

  Widget _buildProductCard(Product product, bool isDark) {
    final imageUrl = _getImageUrl(product);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailScreen(product: product),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor:
                            isDark ? Colors.grey[800]! : Colors.grey[300]!,
                        highlightColor:
                            isDark ? Colors.grey[700]! : Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => _errorBox(),
                    )
                  : _errorBox(),
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
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(height: 2),
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

  Widget _errorBox() {
    return Container(
      color: const Color(0xFF6B4EFF).withOpacity(0.08),
      child: const Icon(Icons.image_not_supported,
          color: Color(0xFF6B4EFF), size: 40),
    );
  }

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

  Widget _buildFloatingButton() {
    return FloatingActionButton(
      shape: const CircleBorder(),
      onPressed: () {
        _scrollController.animateTo(
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