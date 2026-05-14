import 'package:flutter/material.dart';
import 'package:flutter_application_1/provider/product_provider.dart';
import 'package:flutter_application_1/widgets/book_cart.dart';
import 'package:provider/provider.dart';

class SaveScreen extends StatelessWidget {
  const SaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.savedBooks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B4EFF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bookmarks_outlined,
                        size: 64, color: Color(0xFF6B4EFF)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your favourites are empty',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Save products from the Home or Search screen\nto find them here quickly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isDark
                            ? Colors.grey[400]
                            : Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF6B4EFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${provider.savedBooks.length} product${provider.savedBooks.length != 1 ? 's' : ''} saved',
                        style: const TextStyle(
                          color: Color(0xFF6B4EFF),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: provider.savedBooks.length,
                  itemBuilder: (_, i) => BookCard(
                    book: provider.savedBooks[i],
                    isHorizontal: true,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}