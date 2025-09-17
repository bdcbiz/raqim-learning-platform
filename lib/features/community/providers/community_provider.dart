import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/post_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/auth/auth_interface.dart';
import '../../../services/database/database_service.dart';
import '../../../services/unified_data_service.dart';

class CommunityProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  PostModel? _selectedPost;
  bool _isLoading = false;
  String? _error;
  String _sortBy = 'recent';
  final DatabaseService _databaseService = DatabaseService();
  final UnifiedDataService _unifiedDataService = UnifiedDataService();

  List<PostModel> get posts {
    if (_sortBy == 'popular') {
      return [..._posts]..sort((a, b) => b.netVotes.compareTo(a.netVotes));
    }
    return [..._posts]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  PostModel? get selectedPost => _selectedPost;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sortBy => _sortBy;

  CommunityProvider() {
    loadPosts();
  }

  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('DEBUG CommunityProvider: Starting to load posts...');

      // Try to get posts from Firebase first (real data)
      final realPostsData = await _unifiedDataService.getAllPosts();
      if (realPostsData.isNotEmpty) {
        // Convert Firebase data to PostModel objects
        _posts = realPostsData.map((postData) => _convertToPostModel(postData)).toList();
        print('DEBUG CommunityProvider: Loaded ${_posts.length} posts from Firebase (REAL DATA)');
      } else {
        // Fallback to mock data if no real data available
        print('DEBUG CommunityProvider: No real data available, using mock data as fallback');
        _posts = _generateMockPosts();
        print('DEBUG CommunityProvider: Loaded ${_posts.length} posts from mock data (FALLBACK)');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('ERROR CommunityProvider: Failed to load real data: $e');

      // Final fallback to mock data
      try {
        _posts = _generateMockPosts();
        print('DEBUG CommunityProvider: Used mock data as final fallback');
        _isLoading = false;
        notifyListeners();
      } catch (mockError) {
        _error = 'فشل تحميل المنشورات: ${e.toString()}';
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  PostModel _convertToPostModel(Map<String, dynamic> data) {
    return PostModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'مستخدم مجهول',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: data['category'],
      tags: List<String>.from(data['tags'] ?? []),
      images: List<String>.from(data['images'] ?? []),
      upvotes: data['upvotes'] ?? 0,
      downvotes: data['downvotes'] ?? 0,
      upvotedBy: List<String>.from(data['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(data['downvotedBy'] ?? []),
      createdAt: data['createdAt'] is DateTime
          ? data['createdAt']
          : DateTime.now(),
      updatedAt: data['updatedAt'] is DateTime
          ? data['updatedAt']
          : DateTime.now(),
      comments: [], // Comments will be loaded separately when needed
    );
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void selectPost(String postId) {
    _selectedPost = _posts.firstWhere(
      (post) => post.id == postId,
      orElse: () => _posts.first,
    );
    notifyListeners();
  }

  Future<void> createPost(String title, String content, String? category, List<String> tags, List<String> images, BuildContext context) async {
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
        userName = user.name.isNotEmpty ? user.name : user.email;
        userId = user.id;
      }
    } catch (e) {
      // If there's an error getting user info, use defaults
      print('Error getting user info for post: $e');
    }

    // Save post to Firebase first
    String postId;
    try {
      postId = await _unifiedDataService.addPost({
        'userId': userId,
        'userName': userName,
        'title': title,
        'content': content,
        'category': category,
        'tags': tags,
        'images': images,
        'userPhotoUrl': '',
      });
      print('DEBUG CommunityProvider: Created post in Firebase with ID: $postId (REAL DATA)');
    } catch (e) {
      print('DEBUG CommunityProvider: Failed to create post in Firebase, using fallback: $e');
      // Fallback to database service
      postId = await _databaseService.createPost(
        userId: userId,
        userName: userName,
        title: title,
        content: content,
        tags: tags,
      );
    }

    final newPost = PostModel(
      id: postId,
      userId: userId,
      userName: userName,
      title: title,
      content: content,
      category: category,
      tags: tags,
      images: images,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _posts.insert(0, newPost);
    notifyListeners();

    // Track user interaction
    await _databaseService.trackUserInteraction(
      userId: userId,
      action: 'create',
      targetType: 'post',
      targetId: postId,
      metadata: {'title': title, 'tags': tags, 'category': category},
    );
  }

  Future<void> votePost(String postId, bool isUpvote, String userId) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];

      List<String> upvotedBy = [...post.upvotedBy];
      List<String> downvotedBy = [...post.downvotedBy];

      if (isUpvote) {
        if (upvotedBy.contains(userId)) {
          upvotedBy.remove(userId);
        } else {
          upvotedBy.add(userId);
          downvotedBy.remove(userId);
        }
      } else {
        if (downvotedBy.contains(userId)) {
          downvotedBy.remove(userId);
        } else {
          downvotedBy.add(userId);
          upvotedBy.remove(userId);
        }
      }

      _posts[postIndex] = post.copyWith(
        upvotes: upvotedBy.length,
        downvotes: downvotedBy.length,
        upvotedBy: upvotedBy,
        downvotedBy: downvotedBy,
      );

      notifyListeners();

      // Save vote to database
      try {
        await _databaseService.votePost(postId, userId, isUpvote);
        print('DEBUG CommunityProvider: Saved vote to database');
      } catch (e) {
        print('DEBUG CommunityProvider: Failed to save vote: $e');
      }

      // Track user interaction
      await _databaseService.trackUserInteraction(
        userId: userId,
        action: isUpvote ? 'upvote' : 'downvote',
        targetType: 'post',
        targetId: postId,
      );
    }
  }

  Future<void> addComment(String postId, String content, BuildContext context) async {
    try {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];

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
            userName = user.name.isNotEmpty ? user.name : user.email;
            userId = user.id;
          }
        } catch (e) {
          // If there's an error getting user info, use defaults
          print('Error getting user info for comment: $e');
        }

        // Generate a unique comment ID
        String commentId = 'comment_${DateTime.now().millisecondsSinceEpoch}';

        // Create new comment locally first
        final newComment = Comment(
          id: commentId,
          userId: userId,
          userName: userName,
          content: content,
          createdAt: DateTime.now(),
        );

        _posts[postIndex] = post.copyWith(
          comments: [...post.comments, newComment],
        );

        if (_selectedPost?.id == postId) {
          _selectedPost = _posts[postIndex];
        }

        notifyListeners();

        // Try to save to database (but don't fail if it doesn't work)
        try {
          await _databaseService.addComment(
            userId: userId,
            userName: userName,
            content: content,
            targetId: postId,
            targetType: 'post',
          );

          // Track user interaction
          await _databaseService.trackUserInteraction(
            userId: userId,
            action: 'comment',
            targetType: 'post',
            targetId: postId,
            metadata: {'comment_id': commentId},
          );
        } catch (e) {
          // Database operation failed, but local comment was added successfully
          print('Warning: Failed to save comment to database, but added locally: $e');
        }
      }
    } catch (e) {
      print('Error adding comment: $e');
      // Don't throw error to UI, just log it
    }
  }

  List<PostModel> _generateMockPosts() {
    return [
      PostModel(
        id: '1',
        userId: 'user1',
        userName: 'سارة محمد',
        userPhotoUrl: 'https://picsum.photos/150',
        title: 'ورقة بحثية جديدة من OpenAI حول GPT-5',
        content: 'صدرت اليوم ورقة بحثية جديدة من OpenAI تناقش التطورات في GPT-5. الورقة تحتوي على تحسينات مذهلة في الفهم والتوليد.',
        category: 'ai',
        tags: ['أبحاث', 'GPT', 'OpenAI'],
        images: ['https://picsum.photos/800/400'],
        upvotes: 234,
        downvotes: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        comments: [
          Comment(
            id: 'c1',
            userId: 'user2',
            userName: 'أحمد خالد',
            content: 'شكراً للمشاركة! هل يمكنك مشاركة رابط الورقة؟',
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          Comment(
            id: 'c2',
            userId: 'user5',
            userName: 'ليلى حسن',
            content: 'موضوع مثير للاهتمام! متى ستكون متاحة للعامة؟',
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
      ),
      PostModel(
        id: '2',
        userId: 'user3',
        userName: 'محمد عبدالله',
        title: 'كيف بدأت رحلتي في تعلم الذكاء الاصطناعي',
        content: 'أريد أن أشارككم تجربتي في تعلم الذكاء الاصطناعي خلال السنة الماضية. بدأت من الصفر وهذه النصائح التي أود مشاركتها...',
        category: 'ai',
        tags: ['تجربة شخصية', 'نصائح', 'مبتدئين'],
        upvotes: 456,
        downvotes: 23,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        comments: [
          Comment(
            id: 'c3',
            userId: 'user6',
            userName: 'عمر الشريف',
            content: 'ممتاز! ما هي أفضل المصادر للتعلم؟',
            createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          ),
        ],
      ),
      PostModel(
        id: '3',
        userId: 'user4',
        userName: 'فاطمة أحمد',
        title: 'مشروع تخرج: نظام توصية ذكي للمحتوى العربي',
        content: 'أنهيت للتو مشروع تخرجي وهو عبارة عن نظام توصية يستخدم NLP لتحليل المحتوى العربي. النتائج كانت مبهرة!',
        category: 'programming',
        tags: ['مشروع', 'NLP', 'عربي'],
        upvotes: 189,
        downvotes: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PostModel(
        id: '4',
        userId: 'user5',
        userName: 'أحمد السعيد',
        title: 'فرصة عمل: مطور Flutter في شركة تقنية رائدة',
        content: 'نبحث عن مطور Flutter محترف للانضمام إلى فريقنا. الخبرة المطلوبة 3+ سنوات. راتب منافس ومزايا ممتازة.',
        category: 'job_offers',
        tags: ['وظيفة', 'Flutter', 'فرصة عمل'],
        images: ['https://picsum.photos/600/300'],
        upvotes: 78,
        downvotes: 2,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PostModel(
        id: '5',
        userId: 'user6',
        userName: 'نورا علي',
        title: 'أبحث عن وظيفة مصمم UI/UX',
        content: 'مصممة UI/UX بخبرة سنتين أبحث عن فرصة عمل في شركة ناشئة. لدي محفظة أعمال قوية وخبرة في التصميم للمنصات العربية.',
        category: 'job_search',
        tags: ['بحث عن عمل', 'UI/UX', 'تصميم'],
        upvotes: 45,
        downvotes: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      PostModel(
        id: '6',
        userId: 'user7',
        userName: 'كريم حسن',
        title: 'دورة مجانية في تصميم الواجهات',
        content: 'أقدم دورة مجانية في أساسيات تصميم الواجهات باستخدام Figma. ستبدأ الدورة الأسبوع القادم وستكون عبر Zoom.',
        category: 'design',
        tags: ['تصميم', 'Figma', 'دورة'],
        upvotes: 312,
        downvotes: 8,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }
}