// lib/state_manegement/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_application_1/provider/book_provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book.dart';

class DetailScreen extends StatelessWidget {
  final Book book;

  const DetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bookProvider = context.watch<BookProvider>();
    final isSaved = bookProvider.isSaved(book.id);

    // ✅ Safe values with fallbacks
    final category = book.category.isNotEmpty ? book.category : 'General';
    final publishedDate = book.publishedDate.isNotEmpty ? book.publishedDate : 'N/A';
    final language = book.language.isNotEmpty ? book.language : 'EN';
    final author = book.author.isNotEmpty ? book.author : 'Unknown';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: isDark
                ? const Color(0xFF0D0D1A)
                : const Color(0xFFF8F7FF),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => bookProvider.toggleSave(book),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: isSaved ? const Color(0xFF6B4EFF) : null,
                    size: 22,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Blurred background image
                  CachedNetworkImage(
                    imageUrl: book.coverUrl,
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.5),
                    colorBlendMode: BlendMode.darken,
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFF6B4EFF).withOpacity(0.3),
                    ),
                  ),
                  // Centered cover image
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: book.coverUrl,
                            width: 120,
                            height: 170,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              width: 120,
                              height: 170,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B4EFF)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Color(0xFF6B4EFF),
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Title
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Author
                  Text(
                    'by $author',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4EFF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'USD ${book.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stats Row
                  Row(
                    children: [
                      _buildStat(
                        icon: Icons.star_rounded,
                        label: book.rating > 0
                            ? book.rating.toStringAsFixed(1)
                            : 'N/A',
                        color: const Color(0xFFFFB800),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        icon: Icons.menu_book_rounded,
                        label: book.pages > 0
                            ? '${book.pages} pages'
                            : 'N/A',
                        color: const Color(0xFF6B4EFF),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        icon: Icons.language_rounded,
                        label: language.toUpperCase(),
                        color: const Color(0xFF00C9A7),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Star Rating Bar
                  if (book.rating > 0)
                    RatingBarIndicator(
                      rating: book.rating,
                      itemBuilder: (_, __) => const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB800),
                      ),
                      itemCount: 5,
                      itemSize: 22,
                    ),
                  const SizedBox(height: 20),

                  // ✅ Category + Date chips with safe fallbacks
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip(category, const Color(0xFF6B4EFF)),
                      _buildChip(
                        '📅 $publishedDate',
                        const Color(0xFF00C9A7),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description heading
                  Text(
                    'About this product',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description text
                  Text(
                    book.description.isNotEmpty
                        ? book.description
                        : 'No description available.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ✅ Preview button with LaunchMode fixed
                  if (book.previewLink.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(book.previewLink);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        icon: const Icon(Icons.open_in_new_rounded),
                        label: const Text('View Product'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B4EFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Save / Remove button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => bookProvider.toggleSave(book),
                      icon: Icon(
                        isSaved
                            ? Icons.bookmark_remove_rounded
                            : Icons.bookmark_add_rounded,
                      ),
                      label: Text(
                        isSaved ? 'Remove from Library' : 'Save to Library',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B4EFF),
                        side: const BorderSide(color: Color(0xFF6B4EFF)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}