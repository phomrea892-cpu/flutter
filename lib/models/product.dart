class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String coverUrl;
  final String category;
  final String brand;
  final double rating;
  final String publishedDate;
  final String previewLink;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.coverUrl,
    required this.category,
    this.brand = 'Unknown',
    this.rating = 0.0,
    this.publishedDate = '',
    this.previewLink = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String rawImage = (json['image_link'] ??
                    json['api_featured_image'] ??
                    json['image'] ??
                    json['thumbnail'] ?? '')
                    .toString().trim();

    return Product(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['name']?.toString() ?? 'No Title',
      description: json['description']?.toString() ?? 'No description available.',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      coverUrl: _toHttps(rawImage),
      category: _capitalize(json['product_type']?.toString() ?? 'General'),
      brand: _capitalize(json['brand']?.toString() ?? 'Unknown'),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      publishedDate: json['updated_at']?.toString().split('T').first ?? '',
      previewLink: _toHttps(json['product_link']?.toString() ?? ''),
    );
  }

  static String _toHttps(String url) {
    if (url.isEmpty) return '';
    String fixed = url.trim();
    if (fixed.startsWith('https://')) {
      return fixed;
    } else if (fixed.startsWith('http://')) {
      return fixed.replaceFirst('http://', 'https://');
    } else if (fixed.startsWith('//')) {
      return 'https:$fixed';
    } else {
      return 'https://$fixed';
    }
  }

  static String _capitalize(String text) {
    if (text.isEmpty) return 'General';
    return text[0].toUpperCase() + text.substring(1).replaceAll('_', ' ');
  }

  String get name => title;
  String get productType => category;
  double get priceDouble => price;
  String get imageLink => coverUrl;
  String get apiFeaturedImage => coverUrl;
}