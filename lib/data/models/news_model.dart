class NewsModel {
  final String id;
  final String title;
  final String description;
  final String url;
  final String source;
  final String? imageUrl;
  final String category;
  final DateTime publishedAt;
  final String? author;
  final String? content;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    this.imageUrl,
    required this.category,
    required this.publishedAt,
    this.author,
    this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'url': url,
      'source': source,
      'imageUrl': imageUrl,
      'category': category,
      'publishedAt': publishedAt.toIso8601String(),
      'author': author,
      'content': content,
    };
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      source: json['source']?['name'] ?? json['source'] ?? 'Unknown',
      imageUrl: json['urlToImage'] ?? json['imageUrl'],
      category: _categorizeNews(json['title'] ?? '', json['description'] ?? ''),
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt'])
          : DateTime.now(),
      author: json['author'],
      content: json['content'],
    );
  }

  static String _categorizeNews(String title, String description) {
    final text = '$title $description'.toLowerCase();
    
    if (text.contains('research') || text.contains('study') || text.contains('paper')) {
      return 'أبحاث جديدة';
    } else if (text.contains('product') || text.contains('launch') || text.contains('release')) {
      return 'منتجات وتطبيقات';
    } else if (text.contains('investment') || text.contains('funding') || text.contains('million')) {
      return 'استثمارات وتمويل';
    } else if (text.contains('ethics') || text.contains('bias') || text.contains('responsible')) {
      return 'أخلاقيات الذكاء الاصطناعي';
    } else {
      return 'عام';
    }
  }
}