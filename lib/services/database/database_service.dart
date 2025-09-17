// Temporarily using local storage instead of Firestore due to Firebase configuration issues
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/models/post_model.dart';
import '../../data/models/news_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Local storage keys
  static const String _usersKey = 'db_users';
  static const String _postsKey = 'db_posts';
  static const String _newsKey = 'db_news';
  static const String _commentsKey = 'db_comments';
  static const String _enrollmentsKey = 'db_enrollments';
  static const String _interactionsKey = 'db_interactions';

  // Collections
  String get usersCollection => 'users';
  String get postsCollection => 'posts';
  String get newsCollection => 'news';
  String get coursesCollection => 'courses';
  String get commentsCollection => 'comments';
  String get enrollmentsCollection => 'enrollments';
  String get interactionsCollection => 'interactions';

  // User Management
  Future<void> createUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      users[user.id] = {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'photoURL': user.photoUrl,
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'emailVerified': user.emailVerified ?? false,
        'enrolledCourses': [],
        'completedCourses': [],
        'favoritesCourses': [],
        'preferences': {},
      };

      await prefs.setString(_usersKey, jsonEncode(users));
      print('DEBUG DatabaseService: User created successfully: ${user.email}');
    } catch (e) {
      print('ERROR DatabaseService: Failed to create user: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      if (users.containsKey(userId)) {
        final data = users[userId];
        return UserModel(
          id: data['id'],
          name: data['name'],
          email: data['email'],
          photoUrl: data['photoURL'],
          emailVerified: data['emailVerified'] ?? false,
          createdAt: data['createdAt'] != null
              ? DateTime.parse(data['createdAt'])
              : DateTime.now(),
        );
      }
      return null;
    } catch (e) {
      print('ERROR DatabaseService: Failed to get user: $e');
      return null;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      if (users.containsKey(userId)) {
        users[userId] = {...users[userId], ...updates, 'updatedAt': DateTime.now().toIso8601String()};
        await prefs.setString(_usersKey, jsonEncode(users));
        print('DEBUG DatabaseService: User updated successfully');
      }
    } catch (e) {
      print('ERROR DatabaseService: Failed to update user: $e');
      throw Exception('Failed to update user: $e');
    }
  }

  // Comment Management
  Future<String> addComment({
    required String userId,
    required String userName,
    required String content,
    required String targetId,
    required String targetType, // 'post' or 'news'
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString(_commentsKey) ?? '[]';
      final comments = List<Map<String, dynamic>>.from(jsonDecode(commentsJson));

      String commentId = 'comment_${DateTime.now().millisecondsSinceEpoch}';

      comments.add({
        'id': commentId,
        'userId': userId,
        'userName': userName,
        'content': content,
        'targetId': targetId,
        'targetType': targetType,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'likes': 0,
        'likedBy': [],
      });

      await prefs.setString(_commentsKey, jsonEncode(comments));

      // Update target document comment count
      if (targetType == 'post') {
        await _updatePostCommentCount(targetId, 1);
      } else if (targetType == 'news') {
        await _updateNewsCommentCount(targetId, 1);
      }

      print('DEBUG DatabaseService: Comment added successfully');
      return commentId;
    } catch (e) {
      print('ERROR DatabaseService: Failed to add comment: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getComments(String targetId, String targetType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString(_commentsKey) ?? '[]';
      final allComments = List<Map<String, dynamic>>.from(jsonDecode(commentsJson));

      return allComments
          .where((comment) => comment['targetId'] == targetId && comment['targetType'] == targetType)
          .toList()
          ..sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
    } catch (e) {
      print('ERROR DatabaseService: Failed to get comments: $e');
      return [];
    }
  }

  // Post Management
  Future<String> createPost({
    required String userId,
    required String userName,
    required String title,
    required String content,
    required List<String> tags,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = prefs.getString(_postsKey) ?? '[]';
      final posts = List<Map<String, dynamic>>.from(jsonDecode(postsJson));

      String postId = 'post_${DateTime.now().millisecondsSinceEpoch}';

      posts.add({
        'id': postId,
        'userId': userId,
        'userName': userName,
        'userPhotoUrl': '',
        'title': title,
        'content': content,
        'tags': tags,
        'upvotes': 0,
        'downvotes': 0,
        'upvotedBy': [],
        'downvotedBy': [],
        'commentsCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await prefs.setString(_postsKey, jsonEncode(posts));
      print('DEBUG DatabaseService: Post created successfully');
      return postId;
    } catch (e) {
      print('ERROR DatabaseService: Failed to create post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPosts([String sortBy = 'recent']) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = prefs.getString(_postsKey) ?? '[]';
      final posts = List<Map<String, dynamic>>.from(jsonDecode(postsJson));

      // Add net votes calculation
      for (var post in posts) {
        post['netVotes'] = (post['upvotes'] ?? 0) - (post['downvotes'] ?? 0);
      }

      // Sort based on sortBy parameter
      if (sortBy == 'popular') {
        posts.sort((a, b) => b['netVotes'].compareTo(a['netVotes']));
      } else {
        posts.sort((a, b) => DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));
      }

      return posts;
    } catch (e) {
      print('ERROR DatabaseService: Failed to get posts: $e');
      return [];
    }
  }

  Future<void> votePost(String postId, String userId, bool isUpvote) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = prefs.getString(_postsKey) ?? '[]';
      final posts = List<Map<String, dynamic>>.from(jsonDecode(postsJson));

      final postIndex = posts.indexWhere((p) => p['id'] == postId);

      if (postIndex != -1) {
        final post = posts[postIndex];
        List<String> upvotedBy = List<String>.from(post['upvotedBy'] ?? []);
        List<String> downvotedBy = List<String>.from(post['downvotedBy'] ?? []);

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

        post['upvotes'] = upvotedBy.length;
        post['downvotes'] = downvotedBy.length;
        post['upvotedBy'] = upvotedBy;
        post['downvotedBy'] = downvotedBy;
        post['updatedAt'] = DateTime.now().toIso8601String();

        posts[postIndex] = post;
        await prefs.setString(_postsKey, jsonEncode(posts));
        print('DEBUG DatabaseService: Post vote updated successfully');
      }
    } catch (e) {
      print('ERROR DatabaseService: Failed to vote post: $e');
      throw Exception('Failed to vote post: $e');
    }
  }

  // News Management
  Future<void> likeNews(String newsId, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newsJson = prefs.getString(_newsKey) ?? '[]';
      final newsList = List<Map<String, dynamic>>.from(jsonDecode(newsJson));

      final newsIndex = newsList.indexWhere((n) => n['id'] == newsId);

      if (newsIndex != -1) {
        final news = newsList[newsIndex];
        List<String> likedBy = List<String>.from(news['likedBy'] ?? []);

        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
        } else {
          likedBy.add(userId);
        }

        news['likesCount'] = likedBy.length;
        news['likedBy'] = likedBy;
        news['updatedAt'] = DateTime.now().toIso8601String();

        newsList[newsIndex] = news;
        await prefs.setString(_newsKey, jsonEncode(newsList));
        print('DEBUG DatabaseService: News like updated successfully');
      }
    } catch (e) {
      print('ERROR DatabaseService: Failed to like news: $e');
      throw Exception('Failed to like news: $e');
    }
  }

  // Course Management
  Future<void> enrollInCourse(String userId, String courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Update enrollments
      final enrollmentsJson = prefs.getString(_enrollmentsKey) ?? '[]';
      final enrollments = List<Map<String, dynamic>>.from(jsonDecode(enrollmentsJson));

      enrollments.add({
        'userId': userId,
        'courseId': courseId,
        'enrolledAt': DateTime.now().toIso8601String(),
        'progress': 0.0,
        'completed': false,
        'lastAccessedAt': DateTime.now().toIso8601String(),
      });

      await prefs.setString(_enrollmentsKey, jsonEncode(enrollments));

      // Update user's enrolled courses
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      if (users.containsKey(userId)) {
        List<String> enrolledCourses = List<String>.from(users[userId]['enrolledCourses'] ?? []);
        if (!enrolledCourses.contains(courseId)) {
          enrolledCourses.add(courseId);
          users[userId]['enrolledCourses'] = enrolledCourses;
          users[userId]['updatedAt'] = DateTime.now().toIso8601String();
          await prefs.setString(_usersKey, jsonEncode(users));
        }
      }

      print('DEBUG DatabaseService: Course enrollment successful');
    } catch (e) {
      print('ERROR DatabaseService: Failed to enroll in course: $e');
      throw Exception('Failed to enroll in course: $e');
    }
  }

  Future<List<String>> getUserEnrolledCourses(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey) ?? '{}';
      final users = Map<String, dynamic>.from(jsonDecode(usersJson));

      if (users.containsKey(userId)) {
        return List<String>.from(users[userId]['enrolledCourses'] ?? []);
      }
      return [];
    } catch (e) {
      print('ERROR DatabaseService: Failed to get enrolled courses: $e');
      return [];
    }
  }

  Future<void> updateCourseProgress(String userId, String courseId, double progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enrollmentsJson = prefs.getString(_enrollmentsKey) ?? '[]';
      final enrollments = List<Map<String, dynamic>>.from(jsonDecode(enrollmentsJson));

      final enrollmentIndex = enrollments.indexWhere((e) =>
        e['userId'] == userId && e['courseId'] == courseId
      );

      if (enrollmentIndex != -1) {
        enrollments[enrollmentIndex]['progress'] = progress;
        enrollments[enrollmentIndex]['completed'] = progress >= 1.0;
        enrollments[enrollmentIndex]['lastAccessedAt'] = DateTime.now().toIso8601String();
        enrollments[enrollmentIndex]['updatedAt'] = DateTime.now().toIso8601String();

        await prefs.setString(_enrollmentsKey, jsonEncode(enrollments));

        // If completed, add to user's completed courses
        if (progress >= 1.0) {
          final usersJson = prefs.getString(_usersKey) ?? '{}';
          final users = Map<String, dynamic>.from(jsonDecode(usersJson));

          if (users.containsKey(userId)) {
            List<String> completedCourses = List<String>.from(users[userId]['completedCourses'] ?? []);
            if (!completedCourses.contains(courseId)) {
              completedCourses.add(courseId);
              users[userId]['completedCourses'] = completedCourses;
              users[userId]['updatedAt'] = DateTime.now().toIso8601String();
              await prefs.setString(_usersKey, jsonEncode(users));
            }
          }
        }

        print('DEBUG DatabaseService: Course progress updated successfully');
      }
    } catch (e) {
      print('ERROR DatabaseService: Failed to update course progress: $e');
      throw Exception('Failed to update course progress: $e');
    }
  }

  // Helper Methods
  Future<void> _updatePostCommentCount(String postId, int increment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = prefs.getString(_postsKey) ?? '[]';
      final posts = List<Map<String, dynamic>>.from(jsonDecode(postsJson));

      final postIndex = posts.indexWhere((p) => p['id'] == postId);
      if (postIndex != -1) {
        posts[postIndex]['commentsCount'] = (posts[postIndex]['commentsCount'] ?? 0) + increment;
        posts[postIndex]['updatedAt'] = DateTime.now().toIso8601String();
        await prefs.setString(_postsKey, jsonEncode(posts));
      }
    } catch (e) {
      print('ERROR DatabaseService: Failed to update post comment count: $e');
    }
  }

  Future<void> _updateNewsCommentCount(String newsId, int increment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newsJson = prefs.getString(_newsKey) ?? '[]';
      final newsList = List<Map<String, dynamic>>.from(jsonDecode(newsJson));

      final newsIndex = newsList.indexWhere((n) => n['id'] == newsId);
      if (newsIndex != -1) {
        newsList[newsIndex]['commentsCount'] = (newsList[newsIndex]['commentsCount'] ?? 0) + increment;
        newsList[newsIndex]['updatedAt'] = DateTime.now().toIso8601String();
        await prefs.setString(_newsKey, jsonEncode(newsList));
      }
    } catch (e) {
      print('ERROR DatabaseService: Failed to update news comment count: $e');
    }
  }

  // User Interactions Tracking
  Future<void> trackUserInteraction({
    required String userId,
    required String action,
    required String targetType,
    required String targetId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interactionsJson = prefs.getString(_interactionsKey) ?? '[]';
      final interactions = List<Map<String, dynamic>>.from(jsonDecode(interactionsJson));

      interactions.add({
        'userId': userId,
        'action': action, // 'view', 'like', 'comment', 'enroll', 'complete', etc.
        'targetType': targetType, // 'course', 'news', 'post'
        'targetId': targetId,
        'metadata': metadata ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });

      await prefs.setString(_interactionsKey, jsonEncode(interactions));
      print('DEBUG DatabaseService: User interaction tracked: $action on $targetType');
    } catch (e) {
      print('ERROR DatabaseService: Failed to track interaction: $e');
    }
  }

  // Batch operations for better performance
  Future<void> batchCreateComments(List<Map<String, dynamic>> commentsData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString(_commentsKey) ?? '[]';
      final comments = List<Map<String, dynamic>>.from(jsonDecode(commentsJson));

      for (Map<String, dynamic> commentData in commentsData) {
        commentData['id'] = 'comment_${DateTime.now().millisecondsSinceEpoch}_${commentsData.indexOf(commentData)}';
        commentData['createdAt'] = DateTime.now().toIso8601String();
        commentData['updatedAt'] = DateTime.now().toIso8601String();
        comments.add(commentData);
      }

      await prefs.setString(_commentsKey, jsonEncode(comments));
      print('DEBUG DatabaseService: Batch comments created successfully');
    } catch (e) {
      print('ERROR DatabaseService: Failed to batch create comments: $e');
      throw Exception('Failed to batch create comments: $e');
    }
  }

  // Clean up old data (optional maintenance)
  Future<void> cleanupOldInteractions([int daysToKeep = 90]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interactionsJson = prefs.getString(_interactionsKey) ?? '[]';
      final interactions = List<Map<String, dynamic>>.from(jsonDecode(interactionsJson));

      DateTime cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      final filteredInteractions = interactions.where((interaction) {
        DateTime timestamp = DateTime.parse(interaction['timestamp']);
        return timestamp.isAfter(cutoffDate);
      }).toList();

      await prefs.setString(_interactionsKey, jsonEncode(filteredInteractions));
      print('DEBUG DatabaseService: Cleaned up ${interactions.length - filteredInteractions.length} old interactions');
    } catch (e) {
      print('ERROR DatabaseService: Failed to cleanup old interactions: $e');
    }
  }
}