import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/post_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../services/auth/auth_interface.dart';
import '../../../services/database/database_service.dart';
import '../../../services/unified_data_service.dart';
import '../models/prompt_post.dart';

class CommunityProvider extends ChangeNotifier {
  List<PostModel> _posts = [];
  PostModel? _selectedPost;
  List<PromptPost> _prompts = [];
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
  List<PromptPost> get prompts => _prompts;
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

  // Prompt-related methods
  Future<void> loadPrompts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // For now, use mock data for prompts
      _prompts = _generateMockPrompts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل تحميل البرومبت: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPrompt(PromptPost prompt) async {
    _prompts.insert(0, prompt);
    notifyListeners();
  }

  Future<void> copyPrompt(String promptId) async {
    final promptIndex = _prompts.indexWhere((p) => p.id == promptId);
    if (promptIndex != -1) {
      final prompt = _prompts[promptIndex];
      _prompts[promptIndex] = prompt.copyWith(
        copies: prompt.copies + 1,
        copiedBy: [...prompt.copiedBy, 'current_user_id'],
      );
      notifyListeners();
    }
  }

  Future<void> likePrompt(String promptId) async {
    final promptIndex = _prompts.indexWhere((p) => p.id == promptId);
    if (promptIndex != -1) {
      final prompt = _prompts[promptIndex];
      final currentUserId = 'current_user_id';
      final likedBy = [...prompt.likedBy];

      if (likedBy.contains(currentUserId)) {
        likedBy.remove(currentUserId);
      } else {
        likedBy.add(currentUserId);
      }

      _prompts[promptIndex] = prompt.copyWith(
        likes: likedBy.length,
        likedBy: likedBy,
      );
      notifyListeners();
    }
  }

  List<PromptPost> _generateMockPrompts() {
    final now = DateTime.now();
    return [
      PromptPost(
        id: 'p1',
        title: 'برومبت تطوير الكود بطريقة احترافية',
        description: 'برومبت لمساعدة المطورين على كتابة كود نظيف ومنظم مع أفضل الممارسات',
        promptText: 'أريدك أن تعمل كمطور خبير. عندما أعطيك كود، أريدك أن تراجعه وتقترح تحسينات مع شرح السبب وراء كل اقتراح. ركز على:\n\n1. قابلية القراءة والصيانة\n2. الأداء\n3. الأمان\n4. اتباع أفضل الممارسات\n\nالكود: [ضع الكود هنا]',
        category: PromptCategory.coding,
        difficulty: PromptDifficulty.intermediate,
        authorId: 'user1',
        authorName: 'أحمد المطور',
        tags: ['برمجة', 'مراجعة الكود', 'أفضل الممارسات'],
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        likes: 142,
        copies: 89,
        views: 456,
        likedBy: ['user2', 'user3', 'user4'],
        copiedBy: ['user2', 'user5'],
        isVerified: true,
        aiTool: 'ChatGPT',
        exampleOutput: 'سيقوم الـ AI بمراجعة الكود وتقديم اقتراحات مفصلة للتحسين مع أمثلة عملية.',
      ),
      PromptPost(
        id: 'p2',
        title: 'كتابة محتوى تسويقي جذاب',
        description: 'برومبت لإنشاء محتوى تسويقي يجذب العملاء ويزيد المبيعات',
        promptText: 'أريدك أن تعمل كخبير تسويق محتوى. اكتب محتوى تسويقي مقنع لـ [المنتج/الخدمة] يستهدف [الجمهور المستهدف]. يجب أن يتضمن المحتوى:\n\n1. عنوان جذاب\n2. فوائد واضحة\n3. دعوة للعمل قوية\n4. لغة عاطفية مؤثرة\n\nالمنتج/الخدمة: [اوصف المنتج]\nالجمهور المستهدف: [اوصف الجمهور]',
        category: PromptCategory.marketing,
        difficulty: PromptDifficulty.beginner,
        authorId: 'user2',
        authorName: 'سارة التسويق',
        tags: ['تسويق', 'كتابة', 'محتوى'],
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 6)),
        likes: 89,
        copies: 67,
        views: 234,
        aiTool: 'Claude',
        exampleOutput: 'محتوى تسويقي احترافي مع عنوان جذاب ونقاط قوة واضحة ودعوة فعالة للعمل.',
      ),
      PromptPost(
        id: 'p3',
        title: 'تحليل البيانات والاستنتاجات',
        description: 'برومبت لتحليل البيانات واستخراج رؤى قابلة للتنفيذ',
        promptText: 'أريدك أن تعمل كمحلل بيانات خبير. حلل البيانات التالية واستخرج الرؤى المهمة:\n\n[ضع البيانات هنا]\n\nيرجى تقديم:\n1. ملخص للاتجاهات الرئيسية\n2. الأنماط المثيرة للاهتمام\n3. التوصيات القابلة للتنفيذ\n4. الرسوم البيانية المقترحة\n5. المؤشرات المهمة',
        category: PromptCategory.analysis,
        difficulty: PromptDifficulty.advanced,
        authorId: 'user3',
        authorName: 'خالد المحلل',
        tags: ['تحليل', 'بيانات', 'رؤى'],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        likes: 156,
        copies: 123,
        views: 789,
        isVerified: true,
        aiTool: 'GPT-4',
      ),
      PromptPost(
        id: 'p4',
        title: 'كتابة مقالات تعليمية شاملة',
        description: 'برومبت لكتابة مقالات تعليمية مفيدة وسهلة الفهم',
        promptText: 'اكتب مقالاً تعليمياً شاملاً حول موضوع [الموضوع] للمبتدئين. يجب أن يتضمن المقال:\n\n1. مقدمة جذابة تشرح أهمية الموضوع\n2. شرح المفاهيم الأساسية بطريقة بسيطة\n3. أمثلة عملية\n4. نصائح مفيدة\n5. خاتمة تلخص النقاط المهمة\n6. مصادر إضافية للتعلم\n\nالموضوع: [ضع الموضوع هنا]\nالطول المطلوب: [عدد الكلمات]',
        category: PromptCategory.education,
        difficulty: PromptDifficulty.intermediate,
        authorId: 'user4',
        authorName: 'فاطمة الكاتبة',
        tags: ['تعليم', 'كتابة', 'مقالات'],
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now.subtract(const Duration(hours: 12)),
        likes: 78,
        copies: 45,
        views: 167,
        aiTool: 'Gemini',
      ),
      PromptPost(
        id: 'p5',
        title: 'إنشاء قصص إبداعية مشوقة',
        description: 'برومبت لكتابة قصص قصيرة مبدعة ومثيرة للاهتمام',
        promptText: 'اكتب قصة قصيرة مشوقة بالمعايير التالية:\n\n- النوع: [اختر النوع مثل خيال علمي، رومانسية، مغامرة]\n- الشخصية الرئيسية: [اوصف الشخصية]\n- المكان: [حدد المكان والزمان]\n- الصراع: [نوع المشكلة أو التحدي]\n- الطول: 500-800 كلمة\n\nتأكد من وجود:\n1. بداية جذابة\n2. تطور مثير للأحداث\n3. حوارات طبيعية\n4. نهاية مفاجئة أو مؤثرة',
        category: PromptCategory.creative,
        difficulty: PromptDifficulty.beginner,
        authorId: 'user5',
        authorName: 'علي المبدع',
        tags: ['قصص', 'إبداع', 'كتابة أدبية'],
        createdAt: now.subtract(const Duration(hours: 18)),
        updatedAt: now.subtract(const Duration(hours: 18)),
        likes: 234,
        copies: 156,
        views: 567,
        isVerified: true,
        aiTool: 'Claude',
        exampleOutput: 'قصة قصيرة مكتملة العناصر مع شخصيات واقعية وأحداث مترابطة ونهاية مؤثرة.',
      ),
      PromptPost(
        id: 'p6',
        title: 'تطوير خطة عمل شاملة',
        description: 'برومبت لإنشاء خطة عمل احترافية للشركات الناشئة',
        promptText: 'أريدك أن تعمل كمستشار أعمال. اعد خطة عمل شاملة لشركة ناشئة في مجال [المجال]. يجب أن تتضمن الخطة:\n\n1. ملخص تنفيذي\n2. وصف المنتج/الخدمة\n3. تحليل السوق والمنافسين\n4. الاستراتيجية التسويقية\n5. الخطة المالية\n6. فريق العمل\n7. المخاطر والحلول\n8. الجدول الزمني\n\nمعلومات الشركة:\nالمجال: [ضع المجال]\nالمنتج/الخدمة: [الوصف]\nالسوق المستهدف: [الوصف]',
        category: PromptCategory.business,
        difficulty: PromptDifficulty.advanced,
        authorId: 'user6',
        authorName: 'محمد الاستشاري',
        tags: ['أعمال', 'خطة عمل', 'استراتيجية'],
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 8)),
        likes: 167,
        copies: 98,
        views: 345,
        isVerified: true,
        aiTool: 'GPT-4',
      ),
    ];
  }
}