// lib/models/book.dart
class Book {
  final String id;
  final String title;
  final String description;
  final double price;
  final String coverUrl;
  final String category;
  final String author;
  final double rating;
  final int pages;
  final String language;
  final String publishedDate;
  final String previewLink;

  const Book({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.coverUrl,
    required this.category,
    this.author = 'Unknown',
    this.rating = 0.0,
    this.pages = 0,
    this.language = 'EN',
    this.publishedDate = '',
    this.previewLink = '',
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      // ✅ id — never empty
      id: json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),

      // ✅ Basic fields
      title: json['title']?.toString() ?? 'No Title',
      description: json['description']?.toString() ?? 'No description.',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,

      // ✅ DummyJSON uses 'thumbnail'
      coverUrl: json['thumbnail']?.toString() ??
          (json['images'] as List?)?.first?.toString() ?? '',

      // ✅ Category — capitalize first letter
      category: _capitalize(
          json['category']?.toString() ?? 'General'),

      // ✅ DummyJSON uses 'brand' as author
      author: json['brand']?.toString() ??
          json['author']?.toString() ?? 'Unknown',

      // ✅ Rating
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,

      // ✅ Extra fields
      pages: (json['stock'] as num?)?.toInt() ?? 0,
      language: json['language']?.toString() ?? 'EN',
      publishedDate: _parseDate(json),
      previewLink: json['previewLink']?.toString() ?? '',
    );
  }

  // ✅ Capitalize category text
  static String _capitalize(String text) {
    if (text.isEmpty) return 'General';
    return text[0].toUpperCase() + text.substring(1);
  }

  // ✅ Parse date safely from meta.createdAt
  static String _parseDate(Map<String, dynamic> json) {
    try {
      final meta = json['meta'] as Map<String, dynamic>?;
      final raw = meta?['createdAt']?.toString();
      if (raw != null && raw.length >= 10) return raw.substring(0, 10);
    } catch (_) {}
    return '';
  }

  @override
  String toString() => 'Book(id: $id, title: $title)';
}