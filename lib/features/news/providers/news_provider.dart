import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/news_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/api/api_service.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/handlers/error_handler.dart';

class NewsProvider extends ChangeNotifier {
  List<NewsModel> _news = [];
  List<NewsModel> _allNews = []; // لحفظ جميع الأخبار قبل التصفية
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'الكل';
  String _searchQuery = '';
  String? _selectedNewsId; // المتغير الجديد لتتبع الخبر المحدد
  final ApiService _apiService = ApiService.instance;

  List<NewsModel> get news {
    var filteredNews = _allNews;

    // تطبيق فلتر الفئة
    if (_selectedCategory != 'الكل') {
      filteredNews = filteredNews.where((n) => n.category == _selectedCategory).toList();
    }

    // تطبيق فلتر البحث
    if (_searchQuery.isNotEmpty) {
      filteredNews = filteredNews.where((n) =>
        n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        n.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        n.source.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filteredNews;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String? get selectedNewsId => _selectedNewsId;

  // الحصول على الخبر المحدد
  NewsModel? get selectedNews {
    if (_selectedNewsId == null) return null;
    try {
      return _news.firstWhere((news) => news.id == _selectedNewsId);
    } catch (e) {
      return null;
    }
  }

  NewsProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _apiService.initialize();
    await loadNews();
  }

  Future<void> loadNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await ErrorHandler.safeAsyncCall<List<NewsModel>>(
      () async {
        final response = await _apiService.get('/news');

        if (response['data'] != null) {
          final newsData = response['data'] as List;
          return newsData.map((newsJson) => _convertApiResponseToNewsModel(newsJson)).toList();
        } else {
          throw const NetworkException('Invalid API response structure', code: 'invalid_response');
        }
      },
      context: 'Loading news',
      fallbackValue: _generateMockNews(),
    );

    if (result != null) {
      _allNews = result;
      _news = _allNews;
      _error = null;
    } else {
      _error = 'فشل تحميل الأخبار';
      _allNews = _generateMockNews();
      _news = _allNews;
    }

    _isLoading = false;
    notifyListeners();
  }

  NewsModel _convertApiResponseToNewsModel(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['content'] ?? json['description'] ?? '',
      url: json['url'] ?? '',
      source: json['source'] ?? 'رقيم',
      imageUrl: json['image_url'] ?? json['featured_image'] ?? '',
      category: json['category'] ?? 'عام',
      publishedAt: DateTime.tryParse(json['published_at'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      author: json['author'] ?? 'غير محدد',
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      comments: [], // Will be loaded separately when needed
    );
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void searchNews(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // تحديد الخبر المحدد
  void selectNews(String? newsId) {
    _selectedNewsId = newsId;
    notifyListeners();
  }

  Future<void> refreshNews() async {
    await loadNews();
  }

  Future<void> toggleLike(String newsId, String userId) async {
    final newsIndex = _news.indexWhere((n) => n.id == newsId);
    if (newsIndex == -1) return;

    final currentNews = _news[newsIndex];
    final newLikesCount = currentNews.isLiked
        ? currentNews.likesCount - 1
        : currentNews.likesCount + 1;

    _news[newsIndex] = currentNews.copyWith(
      isLiked: !currentNews.isLiked,
      likesCount: newLikesCount,
    );
    notifyListeners();

    final success = await ErrorHandler.safeAsyncCall<bool>(
      () async {
        await _apiService.post('/news/$newsId/like', body: {
          'user_id': userId,
        });
        return true;
      },
      context: 'Toggling news like',
      fallbackValue: false,
    );

    if (success != true) {
      _news[newsIndex] = currentNews;
      notifyListeners();
      _error = 'فشل في تحديث الإعجاب';
    }
  }

  Future<void> addComment(String newsId, String content, BuildContext context) async {
    final newsIndex = _news.indexWhere((n) => n.id == newsId);
    if (newsIndex == -1) return;

    final currentNews = _news[newsIndex];
    String userName = 'المستخدم الحالي';
    String userId = 'current_user';

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user != null) {
        userName = user.name ?? user.email ?? 'المستخدم الحالي';
        userId = user.id ?? 'current_user';
      }
    } catch (e) {
      ErrorHandler.handleError(e, context: 'Getting user info for comment');
    }

    String commentId = 'comment_${DateTime.now().millisecondsSinceEpoch}';

    final newComment = NewsComment(
      id: commentId,
      content: content,
      authorName: userName,
      createdAt: DateTime.now(),
    );

    final updatedComments = List<NewsComment>.from(currentNews.comments ?? []);
    updatedComments.insert(0, newComment);

    _news[newsIndex] = currentNews.copyWith(
      comments: updatedComments,
      commentsCount: updatedComments.length,
    );
    notifyListeners();

    await ErrorHandler.safeAsyncCall<void>(
      () async {
        await _apiService.post('/news/$newsId/comments', body: {
          'content': content,
          'user_id': userId,
        });
      },
      context: 'Adding news comment',
      showError: false,
    );
  }

  List<NewsModel> _generateMockNews() {
    return [
      NewsModel(
        id: '1',
        title: 'Google تطلق نموذج Gemini 2.0 بقدرات متقدمة',
        description: 'أعلنت Google عن إطلاق الإصدار الجديد من نموذج Gemini مع تحسينات كبيرة في الأداء والدقة.',
        url: 'https://example.com/news/1',
        source: 'TechCrunch',
        imageUrl: 'https://picsum.photos/400/225?random=11',
        category: 'منتجات وتطبيقات',
        publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
        author: 'John Doe',
        likesCount: 45,
        commentsCount: 2,
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
        imageUrl: 'https://picsum.photos/400/225?random=12',
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
        imageUrl: 'https://picsum.photos/400/225?random=13',
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
        imageUrl: 'https://picsum.photos/400/225?random=14',
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
        imageUrl: 'https://picsum.photos/400/225?random=15',
        category: 'منتجات وتطبيقات',
        publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        likesCount: 89,
        commentsCount: 34,
        isLiked: true,
      ),
    ];
  }
}