import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/community_provider.dart';
import '../../../core/localization/app_localizations.dart';

class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});
  
  String _getLocalizedPostTitle(dynamic post, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    switch (post.id) {
      case '1':
        return localizations?.translate('discussionTitle1') ?? post.title;
      case '2':
        return localizations?.translate('discussionTitle2') ?? post.title;
      case '3':
        return localizations?.translate('discussionTitle3') ?? post.title;
      case '4':
        return localizations?.translate('discussionTitle4') ?? post.title;
      default:
        return post.title;
    }
  }
  
  String _getLocalizedPostContent(dynamic post, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    switch (post.id) {
      case '1':
        return localizations?.translate('discussionContent1') ?? post.content;
      case '2':
        return localizations?.translate('discussionContent2') ?? post.content;
      case '3':
        return localizations?.translate('discussionContent3') ?? post.content;
      case '4':
        return localizations?.translate('discussionContent4') ?? post.content;
      default:
        return post.content;
    }
  }
  
  String _getLocalizedUserName(dynamic post, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    switch (post.userId) {
      case '1':
        return localizations?.translate('userName1') ?? post.userName;
      case '2':
        return localizations?.translate('userName2') ?? post.userName;
      case '3':
        return localizations?.translate('userName3') ?? post.userName;
      case '4':
        return localizations?.translate('userName4') ?? post.userName;
      default:
        return post.userName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = Provider.of<CommunityProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('communityTitle') ?? 'المجتمع'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => communityProvider.setSortBy(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'recent',
                child: Row(
                  children: [
                    Icon(Icons.access_time),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)?.translate('recent') ?? 'الأحدث'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'popular',
                child: Row(
                  children: [
                    Icon(Icons.trending_up),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)?.translate('popular') ?? 'الأكثر شعبية'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: communityProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => communityProvider.loadPosts(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: communityProvider.posts.length,
                itemBuilder: (context, index) {
                  final post = communityProvider.posts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        communityProvider.selectPost(post.id);
                        context.go('/community/post/${post.id}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: post.userPhotoUrl != null
                                      ? NetworkImage(post.userPhotoUrl!)
                                      : null,
                                  child: post.userPhotoUrl == null
                                      ? Text(post.userName[0])
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getLocalizedUserName(post, context),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _formatTime(post.createdAt, context),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _getLocalizedPostTitle(post, context),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getLocalizedPostContent(post, context),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: post.tags.map((tag) => Chip(
                                label: Text(tag),
                                labelStyle: const TextStyle(fontSize: 12),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              )).toList(),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // Like button
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.favorite,
                                        color: post.upvotedBy.contains('current_user') 
                                            ? Colors.red 
                                            : Colors.grey[600],
                                      ),
                                      onPressed: () => communityProvider.votePost(post.id, true, 'current_user'),
                                    ),
                                    Text('${post.upvotes}'),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                // Dislike button
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.heart_broken,
                                        color: post.downvotedBy.contains('current_user') 
                                            ? Colors.blue 
                                            : Colors.grey[600],
                                      ),
                                      onPressed: () => communityProvider.votePost(post.id, false, 'current_user'),
                                    ),
                                    Text('${post.downvotes}'),
                                  ],
                                ),
                                const Spacer(),
                                // Comments button
                                InkWell(
                                  onTap: () => _showCommentsDialog(context, post, communityProvider),
                                  child: Row(
                                    children: [
                                      Icon(Icons.comment, size: 20, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Text('${post.totalComments}'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/community/create'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCommentsDialog(BuildContext context, dynamic post, CommunityProvider communityProvider) {
    final TextEditingController commentController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  const Text(
                    'التعليقات',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<CommunityProvider>(
                builder: (context, provider, child) {
                  final currentPost = provider.posts.firstWhere((p) => p.id == post.id, orElse: () => post);
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: currentPost.comments.length,
                    itemBuilder: (context, index) {
                      final comment = currentPost.comments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: comment.userPhotoUrl != null
                                  ? NetworkImage(comment.userPhotoUrl!)
                                  : null,
                              child: comment.userPhotoUrl == null
                                  ? Text(comment.userName[0], style: const TextStyle(fontSize: 12))
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment.userName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTime(comment.createdAt, context),
                                        style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(comment.content, style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8,
              ),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'اكتب تعليقاً...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      if (commentController.text.trim().isNotEmpty) {
                        communityProvider.addComment(post.id, commentController.text.trim(), context);
                        commentController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time, BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(time);
    final localizations = AppLocalizations.of(context);
    
    if (diff.inDays > 0) {
      final dayText = diff.inDays == 1 
          ? (localizations?.translate('dayAgo') ?? 'يوم')
          : (localizations?.translate('daysAgo') ?? 'أيام');
      return '${localizations?.translate('since') ?? 'منذ'} ${diff.inDays} $dayText';
    } else if (diff.inHours > 0) {
      final hourText = diff.inHours == 1 
          ? (localizations?.translate('hourAgo') ?? 'ساعة')
          : (localizations?.translate('hoursAgo') ?? 'ساعات');
      return '${localizations?.translate('since') ?? 'منذ'} ${diff.inHours} $hourText';
    } else if (diff.inMinutes > 0) {
      final minuteText = diff.inMinutes == 1 
          ? (localizations?.translate('minuteAgo') ?? 'دقيقة')
          : (localizations?.translate('minutesAgo') ?? 'دقائق');
      return '${localizations?.translate('since') ?? 'منذ'} ${diff.inMinutes} $minuteText';
    } else {
      return localizations?.translate('now') ?? 'الآن';
    }
  }
}