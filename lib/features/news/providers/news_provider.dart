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
      ),
    ];
  }
}