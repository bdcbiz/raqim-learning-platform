import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/news_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/auth/auth_interface.dart';
import '../../../services/database/database_service.dart';

class NewsProvider extends ChangeNotifier {
  List<NewsModel> _news = [];
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'الكل';
  String? _selectedNewsId; // المتغير الجديد لتتبع الخبر المحدد
  final DatabaseService _databaseService = DatabaseService();

  List<NewsModel> get news {
    if (_selectedCategory == 'الكل') {
      return _news;
    }
    return _news.where((n) => n.category == _selectedCategory).toList();
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
    loadNews();
  }

  Future<void> loadNews() async {
    _isLoading = true;
    notifyListeners();

    try {
      // For demo purposes, using mock data
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

  // تحديد الخبر المحدد
  void selectNews(String? newsId) {
    _selectedNewsId = newsId;
    notifyListeners();
  }

  Future<void> refreshNews() async {
    await loadNews();
  }

  Future<void> toggleLike(String newsId, String userId) async {
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

        // Save to database
        await _databaseService.likeNews(newsId, userId);

        // Track user interaction
        await _databaseService.trackUserInteraction(
          userId: userId,
          action: currentNews.isLiked ? 'unlike' : 'like',
          targetType: 'news',
          targetId: newsId,
        );
      }
    } catch (e) {
      _error = 'فشل في تحديث الإعجاب: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> addComment(String newsId, String content, BuildContext context) async {
    try {
      final newsIndex = _news.indexWhere((n) => n.id == newsId);
      if (newsIndex != -1) {
        final currentNews = _news[newsIndex];
        // Get current user information
        String userName = 'المستخدم الحالي';
        String userId = 'current_user';

        try {
          // Try to get user from WebAuthService first (for web)
          final authService = Provider.of<AuthServiceInterface>(context, listen: false);
          final webUser = authService.currentUser;

          // Fallback to AuthProvider
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final authProviderUser = authProvider.currentUser;

          // Use whichever has a user
          final user = webUser ?? authProviderUser;

          if (user != null) {
            userName = user.name ?? user.email ?? 'المستخدم الحالي';
            userId = user.id ?? 'current_user';
          }
        } catch (e) {
          // If there's an error getting user info, use defaults
          print('Error getting user info for news comment: $e');
        }

        // Generate a unique comment ID
        String commentId = 'comment_${DateTime.now().millisecondsSinceEpoch}';

        // Create new comment locally first
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

        // Try to save to database (but don't fail if it doesn't work)
        try {
          await _databaseService.addComment(
            userId: userId,
            userName: userName,
            content: content,
            targetId: newsId,
            targetType: 'news',
          );

          // Track user interaction
          await _databaseService.trackUserInteraction(
            userId: userId,
            action: 'comment',
            targetType: 'news',
            targetId: newsId,
            metadata: {'comment_id': commentId},
          );
        } catch (e) {
          // Database operation failed, but local comment was added successfully
          print('Warning: Failed to save comment to database, but added locally: $e');
        }
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