class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String title;
  final String content;
  final List<String> tags;
  final List<String> images;
  final String? link;
  final int upvotes;
  final int downvotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final List<Comment> comments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final String status;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.title,
    required this.content,
    this.tags = const [],
    this.images = const [],
    this.link,
    this.upvotes = 0,
    this.downvotes = 0,
    this.upvotedBy = const [],
    this.downvotedBy = const [],
    this.comments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.status = 'active',
  });

  int get netVotes => upvotes - downvotes;
  int get totalComments => comments.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'title': title,
      'content': content,
      'tags': tags,
      'images': images,
      'link': link,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
      'comments': comments.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPinned': isPinned,
      'status': status,
    };
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userPhotoUrl: json['userPhotoUrl'],
      title: json['title'],
      content: json['content'],
      tags: List<String>.from(json['tags'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      link: json['link'],
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      upvotedBy: List<String>.from(json['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(json['downvotedBy'] ?? []),
      comments: (json['comments'] as List?)
              ?.map((c) => Comment.fromJson(c))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isPinned: json['isPinned'] ?? false,
      status: json['status'] ?? 'active',
    );
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? title,
    String? content,
    List<String>? tags,
    List<String>? images,
    String? link,
    int? upvotes,
    int? downvotes,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
    List<Comment>? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    String? status,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      link: link ?? this.link,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      status: status ?? this.status,
    );
  }
}

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final DateTime createdAt;
  final int upvotes;
  final int downvotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;
  final String? parentId;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    required this.createdAt,
    this.upvotes = 0,
    this.downvotes = 0,
    this.upvotedBy = const [],
    this.downvotedBy = const [],
    this.parentId,
    this.replies = const [],
  });

  int get netVotes => upvotes - downvotes;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
      'parentId': parentId,
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userPhotoUrl: json['userPhotoUrl'],
      content: json['content'],
      createdAt: DateTime.parse(json['createdAt']),
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      upvotedBy: List<String>.from(json['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(json['downvotedBy'] ?? []),
      parentId: json['parentId'],
      replies: (json['replies'] as List?)
              ?.map((r) => Comment.fromJson(r))
              .toList() ??
          [],
    );
  }
}