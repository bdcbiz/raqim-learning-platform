import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/post_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/auth/auth_interface.dart';
import '../../../services/database/database_service.dart';

class CommunityProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  PostModel? _selectedPost;
  bool _isLoading = false;
  String? _error;
  String _sortBy = 'recent';
  final DatabaseService _databaseService = DatabaseService();

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
      await Future.delayed(const Duration(seconds: 1));
      _posts = _generateMockPosts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل تحميل المنشورات: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
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

  Future<void> createPost(String title, String content, List<String> tags, BuildContext context) async {
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
      print('Error getting user info for post: $e');
    }

    // Save post to database first
    String postId = await _databaseService.createPost(
      userId: userId,
      userName: userName,
      title: title,
      content: content,
      tags: tags,
    );

    final newPost = PostModel(
      id: postId,
      userId: userId,
      userName: userName,
      title: title,
      content: content,
      tags: tags,
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
      metadata: {'title': title, 'tags': tags},
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
      await _databaseService.votePost(postId, userId, isUpvote);

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
            userName = user.name ?? user.email ?? 'المستخدم الحالي';
            userId = user.id ?? 'current_user';
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
        tags: ['أبحاث', 'GPT', 'OpenAI'],
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
        tags: ['مشروع', 'NLP', 'عربي'],
        upvotes: 189,
        downvotes: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}