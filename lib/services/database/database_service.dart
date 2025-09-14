import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';
import '../../data/models/post_model.dart';
import '../../data/models/news_model.dart';
import '../../data/models/course_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      await _firestore.collection(usersCollection).doc(user.id).set({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'photoURL': user.photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'emailVerified': user.emailVerified ?? false,
        'enrolledCourses': [],
        'completedCourses': [],
        'favoritesCourses': [],
        'preferences': {},
      });
      print('DEBUG DatabaseService: User created successfully: ${user.email}');
    } catch (e) {
      print('ERROR DatabaseService: Failed to create user: $e');
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(usersCollection).doc(userId).get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel(
          id: data['id'],
          name: data['name'],
          email: data['email'],
          photoUrl: data['photoURL'],
          emailVerified: data['emailVerified'] ?? false,
          createdAt: data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
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
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(usersCollection).doc(userId).update(updates);
      print('DEBUG DatabaseService: User updated successfully');
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
      DocumentReference commentRef = await _firestore.collection(commentsCollection).add({
        'id': '',
        'userId': userId,
        'userName': userName,
        'content': content,
        'targetId': targetId,
        'targetType': targetType,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
      });

      // Update the comment with its generated ID
      await commentRef.update({'id': commentRef.id});

      // Update target document comment count
      if (targetType == 'post') {
        await _updatePostCommentCount(targetId, 1);
      } else if (targetType == 'news') {
        await _updateNewsCommentCount(targetId, 1);
      }

      print('DEBUG DatabaseService: Comment added successfully');
      return commentRef.id;
    } catch (e) {
      print('ERROR DatabaseService: Failed to add comment: $e');
      throw Exception('Failed to add comment: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getComments(String targetId, String targetType) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(commentsCollection)
          .where('targetId', isEqualTo: targetId)
          .where('targetType', isEqualTo: targetType)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'userId': data['userId'],
          'userName': data['userName'],
          'content': data['content'],
          'createdAt': data['createdAt'],
          'likes': data['likes'] ?? 0,
          'likedBy': List<String>.from(data['likedBy'] ?? []),
        };
      }).toList();
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
      DocumentReference postRef = await _firestore.collection(postsCollection).add({
        'id': '',
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
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await postRef.update({'id': postRef.id});

      print('DEBUG DatabaseService: Post created successfully');
      return postRef.id;
    } catch (e) {
      print('ERROR DatabaseService: Failed to create post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPosts([String sortBy = 'recent']) async {
    try {
      Query query = _firestore.collection(postsCollection);

      if (sortBy == 'popular') {
        // For popular, we'll sort by net votes (upvotes - downvotes)
        query = query.orderBy('createdAt', descending: true);
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      QuerySnapshot snapshot = await query.get();

      List<Map<String, dynamic>> posts = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['netVotes'] = (data['upvotes'] ?? 0) - (data['downvotes'] ?? 0);
        return data;
      }).toList();

      // Sort by popularity if needed (since Firestore can't sort by calculated field)
      if (sortBy == 'popular') {
        posts.sort((a, b) => b['netVotes'].compareTo(a['netVotes']));
      }

      return posts;
    } catch (e) {
      print('ERROR DatabaseService: Failed to get posts: $e');
      return [];
    }
  }

  Future<void> votePost(String postId, String userId, bool isUpvote) async {
    try {
      DocumentReference postRef = _firestore.collection(postsCollection).doc(postId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(postRef);

        if (!snapshot.exists) {
          throw Exception('Post not found');
        }

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        List<String> upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
        List<String> downvotedBy = List<String>.from(data['downvotedBy'] ?? []);

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

        transaction.update(postRef, {
          'upvotes': upvotedBy.length,
          'downvotes': downvotedBy.length,
          'upvotedBy': upvotedBy,
          'downvotedBy': downvotedBy,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      print('DEBUG DatabaseService: Post vote updated successfully');
    } catch (e) {
      print('ERROR DatabaseService: Failed to vote post: $e');
      throw Exception('Failed to vote post: $e');
    }
  }

  // News Management
  Future<void> likeNews(String newsId, String userId) async {
    try {
      DocumentReference newsRef = _firestore.collection(newsCollection).doc(newsId);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(newsRef);

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          List<String> likedBy = List<String>.from(data['likedBy'] ?? []);

          if (likedBy.contains(userId)) {
            likedBy.remove(userId);
          } else {
            likedBy.add(userId);
          }

          transaction.update(newsRef, {
            'likesCount': likedBy.length,
            'likedBy': likedBy,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      print('DEBUG DatabaseService: News like updated successfully');
    } catch (e) {
      print('ERROR DatabaseService: Failed to like news: $e');
      throw Exception('Failed to like news: $e');
    }
  }

  // Course Management
  Future<void> enrollInCourse(String userId, String courseId) async {
    try {
      await _firestore.collection(enrollmentsCollection).add({
        'userId': userId,
        'courseId': courseId,
        'enrolledAt': FieldValue.serverTimestamp(),
        'progress': 0.0,
        'completed': false,
        'lastAccessedAt': FieldValue.serverTimestamp(),
      });

      // Update user's enrolled courses
      await _firestore.collection(usersCollection).doc(userId).update({
        'enrolledCourses': FieldValue.arrayUnion([courseId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('DEBUG DatabaseService: Course enrollment successful');
    } catch (e) {
      print('ERROR DatabaseService: Failed to enroll in course: $e');
      throw Exception('Failed to enroll in course: $e');
    }
  }

  Future<List<String>> getUserEnrolledCourses(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection(usersCollection).doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return List<String>.from(data['enrolledCourses'] ?? []);
      }
      return [];
    } catch (e) {
      print('ERROR DatabaseService: Failed to get enrolled courses: $e');
      return [];
    }
  }

  Future<void> updateCourseProgress(String userId, String courseId, double progress) async {
    try {
      QuerySnapshot enrollmentSnapshot = await _firestore
          .collection(enrollmentsCollection)
          .where('userId', isEqualTo: userId)
          .where('courseId', isEqualTo: courseId)
          .get();

      if (enrollmentSnapshot.docs.isNotEmpty) {
        String enrollmentId = enrollmentSnapshot.docs.first.id;

        await _firestore.collection(enrollmentsCollection).doc(enrollmentId).update({
          'progress': progress,
          'completed': progress >= 1.0,
          'lastAccessedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // If completed, add to user's completed courses
        if (progress >= 1.0) {
          await _firestore.collection(usersCollection).doc(userId).update({
            'completedCourses': FieldValue.arrayUnion([courseId]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      print('DEBUG DatabaseService: Course progress updated successfully');
    } catch (e) {
      print('ERROR DatabaseService: Failed to update course progress: $e');
      throw Exception('Failed to update course progress: $e');
    }
  }

  // Helper Methods
  Future<void> _updatePostCommentCount(String postId, int increment) async {
    try {
      await _firestore.collection(postsCollection).doc(postId).update({
        'commentsCount': FieldValue.increment(increment),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('ERROR DatabaseService: Failed to update post comment count: $e');
    }
  }

  Future<void> _updateNewsCommentCount(String newsId, int increment) async {
    try {
      await _firestore.collection(newsCollection).doc(newsId).update({
        'commentsCount': FieldValue.increment(increment),
        'updatedAt': FieldValue.serverTimestamp(),
      });
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
      await _firestore.collection(interactionsCollection).add({
        'userId': userId,
        'action': action, // 'view', 'like', 'comment', 'enroll', 'complete', etc.
        'targetType': targetType, // 'course', 'news', 'post'
        'targetId': targetId,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('DEBUG DatabaseService: User interaction tracked: $action on $targetType');
    } catch (e) {
      print('ERROR DatabaseService: Failed to track interaction: $e');
    }
  }

  // Batch operations for better performance
  Future<void> batchCreateComments(List<Map<String, dynamic>> commentsData) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (Map<String, dynamic> commentData in commentsData) {
        DocumentReference commentRef = _firestore.collection(commentsCollection).doc();
        commentData['id'] = commentRef.id;
        commentData['createdAt'] = FieldValue.serverTimestamp();
        commentData['updatedAt'] = FieldValue.serverTimestamp();

        batch.set(commentRef, commentData);
      }

      await batch.commit();
      print('DEBUG DatabaseService: Batch comments created successfully');
    } catch (e) {
      print('ERROR DatabaseService: Failed to batch create comments: $e');
      throw Exception('Failed to batch create comments: $e');
    }
  }

  // Clean up old data (optional maintenance)
  Future<void> cleanupOldInteractions([int daysToKeep = 90]) async {
    try {
      DateTime cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));

      QuerySnapshot oldInteractions = await _firestore
          .collection(interactionsCollection)
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      WriteBatch batch = _firestore.batch();

      for (QueryDocumentSnapshot doc in oldInteractions.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('DEBUG DatabaseService: Cleaned up ${oldInteractions.docs.length} old interactions');
    } catch (e) {
      print('ERROR DatabaseService: Failed to cleanup old interactions: $e');
    }
  }
}