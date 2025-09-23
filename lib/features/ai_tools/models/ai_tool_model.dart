import 'package:flutter/material.dart';

class AITool {
  final String id;
  final String name;
  final String description;
  final String category;
  final IconData iconData;
  final Color color;
  final String url;
  final bool isPopular;
  final String? imageUrl;

  const AITool({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconData,
    required this.color,
    required this.url,
    this.isPopular = false,
    this.imageUrl,
  });

  factory AITool.fromJson(Map<String, dynamic> json) {
    return AITool(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      iconData: _getIconFromString(json['icon']),
      color: Color(json['color'] ?? 0xFF6366F1),
      url: json['url'] ?? '',
      isPopular: json['isPopular'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'icon': _getStringFromIcon(iconData),
      'color': color.value,
      'url': url,
      'isPopular': isPopular,
      'imageUrl': imageUrl,
    };
  }

  static IconData _getIconFromString(String? iconString) {
    switch (iconString) {
      case 'chat':
        return Icons.chat;
      case 'psychology':
        return Icons.psychology;
      case 'edit':
        return Icons.edit;
      case 'content_copy':
        return Icons.content_copy;
      case 'palette':
        return Icons.palette;
      case 'image':
        return Icons.image;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'design_services':
        return Icons.design_services;
      case 'movie':
        return Icons.movie;
      case 'record_voice_over':
        return Icons.record_voice_over;
      case 'play_arrow':
        return Icons.play_arrow;
      case 'code':
        return Icons.code;
      case 'terminal':
        return Icons.terminal;
      case 'memory':
        return Icons.memory;
      case 'analytics':
        return Icons.analytics;
      case 'smart_toy':
        return Icons.smart_toy;
      case 'note':
        return Icons.note;
      case 'spellcheck':
        return Icons.spellcheck;
      case 'transcribe':
        return Icons.transcribe;
      case 'event':
        return Icons.event;
      default:
        return Icons.help;
    }
  }

  static String _getStringFromIcon(IconData iconData) {
    if (iconData == Icons.chat) return 'chat';
    if (iconData == Icons.psychology) return 'psychology';
    if (iconData == Icons.edit) return 'edit';
    if (iconData == Icons.content_copy) return 'content_copy';
    if (iconData == Icons.palette) return 'palette';
    if (iconData == Icons.image) return 'image';
    if (iconData == Icons.auto_awesome) return 'auto_awesome';
    if (iconData == Icons.design_services) return 'design_services';
    if (iconData == Icons.movie) return 'movie';
    if (iconData == Icons.record_voice_over) return 'record_voice_over';
    if (iconData == Icons.play_arrow) return 'play_arrow';
    if (iconData == Icons.code) return 'code';
    if (iconData == Icons.terminal) return 'terminal';
    if (iconData == Icons.memory) return 'memory';
    if (iconData == Icons.analytics) return 'analytics';
    if (iconData == Icons.smart_toy) return 'smart_toy';
    if (iconData == Icons.note) return 'note';
    if (iconData == Icons.spellcheck) return 'spellcheck';
    if (iconData == Icons.transcribe) return 'transcribe';
    if (iconData == Icons.event) return 'event';
    return 'help';
  }
}