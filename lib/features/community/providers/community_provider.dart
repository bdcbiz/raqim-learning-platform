import 'package:flutter/material.dart';
import '../../../data/models/post_model.dart';

class CommunityProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  PostModel? _selectedPost;
  bool _isLoading = false;
  String? _error;
  String _sortBy = 'recent';

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

  Future<void> createPost(String title, String content, List<String> tags) async {
    final newPost = PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user',
      userName: 'المستخدم الحالي',
      title: title,
      content: content,
      tags: tags,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _posts.insert(0, newPost);
    notifyListeners();
  }

  Future<void> votePost(String postId, bool isUpvote) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final userId = 'current_user';

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
    }
  }

  Future<void> addComment(String postId, String content) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final newComment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user',
        userName: 'المستخدم الحالي',
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