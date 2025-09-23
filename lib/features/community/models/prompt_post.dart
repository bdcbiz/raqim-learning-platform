import 'package:flutter/foundation.dart';

enum PromptCategory {
  creative,
  coding,
  business,
  education,
  marketing,
  writing,
  analysis,
  other,
}

enum PromptDifficulty {
  beginner,
  intermediate,
  advanced,
}

class PromptPost {
  final String id;
  final String title;
  final String description;
  final String promptText;
  final PromptCategory category;
  final PromptDifficulty difficulty;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final int copies;
  final int views;
  final List<String> likedBy;
  final List<String> copiedBy;
  final bool isVerified;
  final String? aiTool; // Which AI tool this prompt is designed for
  final String? exampleOutput; // Example of what this prompt produces
  final Map<String, String>? variables; // Variables that can be customized

  const PromptPost({
    required this.id,
    required this.title,
    required this.description,
    required this.promptText,
    required this.category,
    required this.difficulty,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.likes = 0,
    this.copies = 0,
    this.views = 0,
    this.likedBy = const [],
    this.copiedBy = const [],
    this.isVerified = false,
    this.aiTool,
    this.exampleOutput,
    this.variables,
  });

  factory PromptPost.fromJson(Map<String, dynamic> json) {
    return PromptPost(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      promptText: json['promptText'] ?? '',
      category: _parseCategoryFromString(json['category']),
      difficulty: _parseDifficultyFromString(json['difficulty']),
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      authorAvatar: json['authorAvatar'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      likes: json['likes'] ?? 0,
      copies: json['copies'] ?? 0,
      views: json['views'] ?? 0,
      likedBy: List<String>.from(json['likedBy'] ?? []),
      copiedBy: List<String>.from(json['copiedBy'] ?? []),
      isVerified: json['isVerified'] ?? false,
      aiTool: json['aiTool'],
      exampleOutput: json['exampleOutput'],
      variables: json['variables'] != null
          ? Map<String, String>.from(json['variables'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'promptText': promptText,
      'category': category.name,
      'difficulty': difficulty.name,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'likes': likes,
      'copies': copies,
      'views': views,
      'likedBy': likedBy,
      'copiedBy': copiedBy,
      'isVerified': isVerified,
      'aiTool': aiTool,
      'exampleOutput': exampleOutput,
      'variables': variables,
    };
  }

  PromptPost copyWith({
    String? id,
    String? title,
    String? description,
    String? promptText,
    PromptCategory? category,
    PromptDifficulty? difficulty,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likes,
    int? copies,
    int? views,
    List<String>? likedBy,
    List<String>? copiedBy,
    bool? isVerified,
    String? aiTool,
    String? exampleOutput,
    Map<String, String>? variables,
  }) {
    return PromptPost(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      promptText: promptText ?? this.promptText,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      copies: copies ?? this.copies,
      views: views ?? this.views,
      likedBy: likedBy ?? this.likedBy,
      copiedBy: copiedBy ?? this.copiedBy,
      isVerified: isVerified ?? this.isVerified,
      aiTool: aiTool ?? this.aiTool,
      exampleOutput: exampleOutput ?? this.exampleOutput,
      variables: variables ?? this.variables,
    );
  }

  static PromptCategory _parseCategoryFromString(String? category) {
    switch (category?.toLowerCase()) {
      case 'creative':
        return PromptCategory.creative;
      case 'coding':
        return PromptCategory.coding;
      case 'business':
        return PromptCategory.business;
      case 'education':
        return PromptCategory.education;
      case 'marketing':
        return PromptCategory.marketing;
      case 'writing':
        return PromptCategory.writing;
      case 'analysis':
        return PromptCategory.analysis;
      default:
        return PromptCategory.other;
    }
  }

  static PromptDifficulty _parseDifficultyFromString(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'beginner':
        return PromptDifficulty.beginner;
      case 'intermediate':
        return PromptDifficulty.intermediate;
      case 'advanced':
        return PromptDifficulty.advanced;
      default:
        return PromptDifficulty.beginner;
    }
  }

  // Helper methods
  String get categoryDisplayName {
    switch (category) {
      case PromptCategory.creative:
        return 'إبداعي';
      case PromptCategory.coding:
        return 'برمجة';
      case PromptCategory.business:
        return 'أعمال';
      case PromptCategory.education:
        return 'تعليم';
      case PromptCategory.marketing:
        return 'تسويق';
      case PromptCategory.writing:
        return 'كتابة';
      case PromptCategory.analysis:
        return 'تحليل';
      case PromptCategory.other:
        return 'أخرى';
    }
  }

  String get difficultyDisplayName {
    switch (difficulty) {
      case PromptDifficulty.beginner:
        return 'مبتدئ';
      case PromptDifficulty.intermediate:
        return 'متوسط';
      case PromptDifficulty.advanced:
        return 'متقدم';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PromptPost &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PromptPost(id: $id, title: $title, category: $category, difficulty: $difficulty)';
  }
}