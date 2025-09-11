class NewsComment {
  final String id;
  final String content;
  final String authorName;
  final String? authorAvatar;
  final DateTime createdAt;

  NewsComment({
    required this.id,
    required this.content,
    required this.authorName,
    this.authorAvatar,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NewsComment.fromJson(Map<String, dynamic> json) {
    return NewsComment(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      authorName: json['authorName'] ?? '',
      authorAvatar: json['authorAvatar'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

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
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final List<NewsComment>? comments;

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
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.comments,
  });

  NewsModel copyWith({
    String? id,
    String? title,
    String? description,
    String? url,
    String? source,
    String? imageUrl,
    String? category,
    DateTime? publishedAt,
    String? author,
    String? content,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    List<NewsComment>? comments,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      url: url ?? this.url,
      source: source ?? this.source,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      publishedAt: publishedAt ?? this.publishedAt,
      author: author ?? this.author,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
    );
  }

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
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLiked': isLiked,
      'comments': comments?.map((c) => c.toJson()).toList(),
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
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      comments: json['comments'] != null 
          ? (json['comments'] as List).map((c) => NewsComment.fromJson(c)).toList()
          : null,
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