// lib/widgets/book_cart.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/provider/product_provider.dart';
import 'package:flutter_application_1/state_manegement/detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class BookCard extends StatelessWidget {
  final Product book;
  final bool isHorizontal;

  const BookCard({
    super.key,
    required this.book,
    this.isHorizontal = false,
  });

  void _goToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(product: book)),
    );
  }

  String _getImageUrl() {
    final candidates = [
      book.imageLink,
      book.apiFeaturedImage,
      book.coverUrl,
    ];
    for (final url in candidates) {
      if (url.toString().trim().isNotEmpty) {
        String fixed = url.toString().trim();
        if (fixed.startsWith('http://')) {
          fixed = fixed.replaceFirst('http://', 'https://');
        }
        if (!fixed.startsWith('http')) {
          fixed = 'https://$fixed';
        }
        return fixed;
      }
    }
    return 'https://picsum.photos/id/237/300/300';
  }

  Widget _buildImage({
    required double width,
    required double height,
    required bool isDark,
    BorderRadius borderRadius = BorderRadius.zero,
  }) {
    final imageUrl = _getImageUrl();
    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => _shimmerBox(width, height, isDark),
        errorWidget: (_, __, ___) => _placeholderBox(width, height),
        fadeInDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  Widget _shimmerBox(double width, double height, bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(width: width, height: height, color: Colors.white),
    );
  }

  Widget _placeholderBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_rounded,
              size: 40, color: Colors.grey),
          SizedBox(height: 4),
          Text('No Image',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHorizontal(
    BuildContext context,
    bool isDark,
    bool isSaved,
    ProductProvider provider,
  ) {
    return GestureDetector(
      onTap: () => _goToDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildImage(
              width: 90,
              height: 110,
              isDark: isDark,
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.productType,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'USD ${book.priceDouble.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B4EFF),
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => provider.toggleSave(book),
                          child: Icon(
                            isSaved
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: isSaved
                                ? const Color(0xFF6B4EFF)
                                : Colors.grey,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVertical(
    BuildContext context,
    bool isDark,
    bool isSaved,
    ProductProvider provider,
  ) {
    return GestureDetector(
      onTap: () => _goToDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildImage(
                  width: double.infinity,
                  height: 160,
                  isDark: isDark,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => provider.toggleSave(book),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: isSaved
                            ? const Color(0xFF6B4EFF)
                            : Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'USD ${book.priceDouble.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B4EFF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ProductProvider>();
    final isSaved = provider.isSaved(book.id);

    return isHorizontal
        ? _buildHorizontal(context, isDark, isSaved, provider)
        : _buildVertical(context, isDark, isSaved, provider);
  }
}