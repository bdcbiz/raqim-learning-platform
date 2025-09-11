import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../data/models/news_model.dart';
import '../../../core/constants/app_constants.dart';

class NewsProvider extends ChangeNotifier {
  List<NewsModel> _news = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'الكل';

  List<NewsModel> get news {
    if (_selectedCategory == 'الكل') {
      return _news;
    }
    return _news.where((n) => n.category == _selectedCategory).toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  NewsProvider() {
    loadNews();
  }

  Future<void> loadNews() async {
    _isLoading = true;
    notifyListeners();

    try {
      // For demo purposes, using mock data
      // In production, uncomment the API call below
      await Future.delayed(const Duration(seconds: 1));
      _news = _generateMockNews();
      
      /* Uncomment for real API integration
      final response = await http.get(
        Uri.parse('${AppConstants.newsApiUrl}/everything?q=artificial+intelligence&apiKey=${AppConstants.newsApiKey}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articles = data['articles'] as List;
        _news = articles.map((article) => NewsModel.fromJson(article)).toList();
      } else {
        throw Exception('Failed to load news');
      }
      */
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل تحميل الأخبار: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> refreshNews() async {
    await loadNews();
  }

  Future<void> toggleLike(String newsId) async {
    try {
      final newsIndex = _news.indexWhere((n) => n.id == newsId);
      if (newsIndex != -1) {
        final currentNews = _news[newsIndex];
        final newLikesCount = currentNews.isLiked 
            ? currentNews.likesCount - 1 
            : currentNews.likesCount + 1;
            
        _news[newsIndex] = currentNews.copyWith(
          isLiked: !currentNews.isLiked,
          likesCount: newLikesCount,
        );
        
        notifyListeners();
        
        // In production, send API request to backend
        // await http.put(Uri.parse('${AppConstants.baseUrl}/api/v1/news/$newsId/like'));
      }
    } catch (e) {
      _error = 'فشل في تحديث الإعجاب: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> addComment(String newsId, String content) async {
    try {
      final newsIndex = _news.indexWhere((n) => n.id == newsId);
      if (newsIndex != -1) {
        final currentNews = _news[newsIndex];
        final newComment = NewsComment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: content,
          authorName: 'المستخدم الحالي', // In production, get from auth
          createdAt: DateTime.now(),
        );
        
        final updatedComments = List<NewsComment>.from(currentNews.comments ?? []);
        updatedComments.insert(0, newComment);
        
        _news[newsIndex] = currentNews.copyWith(
          comments: updatedComments,
          commentsCount: updatedComments.length,
        );
        
        notifyListeners();
        
        // In production, send API request to backend
        // await http.post(Uri.parse('${AppConstants.baseUrl}/api/v1/news/$newsId/comments'));
      }
    } catch (e) {
      _error = 'فشل في إضافة التعليق: ${e.toString()}';
      notifyListeners();
    }
  }

  List<NewsModel> _generateMockNews() {
    return [
      NewsModel(
        id: '1',
        title: 'Google تطلق نموذج Gemini 2.0 بقدرات متقدمة',
        description: 'أعلنت Google عن إطلاق الإصدار الجديد من نموذج Gemini مع تحسينات كبيرة في الأداء والدقة.',
        url: 'https://example.com/news/1',
        source: 'TechCrunch',
        imageUrl: 'https://picsum.photos/400x225',
        category: 'منتجات وتطبيقات',
        publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
        author: 'John Doe',
        likesCount: 45,
        commentsCount: 8,
        isLiked: false,
        comments: [
          NewsComment(
            id: '1',
            content: 'إنجاز رائع من Google! متحمس لتجربة هذا النموذج الجديد.',
            authorName: 'أحمد محمد',
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
          NewsComment(
            id: '2',
            content: 'هل سيكون أفضل من GPT-4؟ أتطلع لرؤية المقارنات.',
            authorName: 'سارة أحمد',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      NewsModel(
        id: '2',
        title: 'استثمار بقيمة 500 مليون دولار في شركة AI ناشئة',
        description: 'شركة ناشئة متخصصة في الذكاء الاصطناعي تحصل على تمويل ضخم لتطوير حلولها.',
        url: 'https://example.com/news/2',
        source: 'Forbes',
        imageUrl: 'https://picsum.photos/400x225',
        category: 'استثمارات وتمويل',
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        likesCount: 32,
        commentsCount: 5,
        isLiked: true,
        comments: [
          NewsComment(
            id: '3',
            content: 'استثمار ضخم! هذا يؤكد أن الذكاء الاصطناعي هو مستقبل التكنولوجيا.',
            authorName: 'محمد علي',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      NewsModel(
        id: '3',
        title: 'دراسة جديدة حول أخلاقيات الذكاء الاصطناعي في الطب',
        description: 'باحثون من MIT ينشرون دراسة شاملة حول التحديات الأخلاقية لاستخدام AI في التشخيص الطبي.',
        url: 'https://example.com/news/3',
        source: 'MIT News',
        imageUrl: 'https://picsum.photos/400x225',
        category: 'أخلاقيات الذكاء الاصطناعي',
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        author: 'Dr. Sarah Johnson',
        likesCount: 18,
        commentsCount: 12,
        isLiked: false,
      ),
      NewsModel(
        id: '4',
        title: 'OpenAI تنشر ورقة بحثية حول تحسين كفاءة النماذج اللغوية',
        description: 'تقنيات جديدة لتقليل استهلاك الموارد مع الحفاظ على الأداء العالي للنماذج.',
        url: 'https://example.com/news/4',
        source: 'OpenAI Blog',
        imageUrl: 'https://picsum.photos/400x225',
        category: 'أبحاث جديدة',
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        likesCount: 56,
        commentsCount: 23,
        isLiked: false,
      ),
      NewsModel(
        id: '5',
        title: 'Microsoft تدمج Copilot في جميع منتجاتها',
        description: 'خطة شاملة لدمج مساعد الذكاء الاصطناعي في كافة تطبيقات Microsoft Office.',
        url: 'https://example.com/news/5',
        source: 'The Verge',
        imageUrl: 'https://picsum.photos/400x225',
        category: 'منتجات وتطبيقات',
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        likesCount: 89,
        commentsCount: 34,
        isLiked: true,
      ),
    ];
  }
}