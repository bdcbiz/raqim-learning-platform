import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

class ModernPostCard extends StatelessWidget {
  final dynamic post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final String Function(dynamic) getLocalizedTitle;
  final String Function(dynamic) getLocalizedContent;
  final String Function(dynamic) getLocalizedUserName;
  final String Function(DateTime) formatTime;
  final String? categoryName;

  const ModernPostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onLike,
    required this.onComment,
    required this.getLocalizedTitle,
    required this.getLocalizedContent,
    required this.getLocalizedUserName,
    required this.formatTime,
    this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id ?? 'guest_user';
    final isLiked = post.upvotedBy?.contains(userId) ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // User avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: post.userPhotoUrl != null
                        ? NetworkImage(post.userPhotoUrl!)
                        : null,
                    backgroundColor: Colors.transparent,
                    child: post.userPhotoUrl == null
                        ? Text(
                            getLocalizedUserName(post)[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // User name and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            getLocalizedUserName(post),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          if (categoryName != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                categoryName!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatTime(post.createdAt),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Post content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (getLocalizedTitle(post).isNotEmpty)
                  Text(
                    getLocalizedTitle(post),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                if (getLocalizedTitle(post).isNotEmpty)
                  const SizedBox(height: 8),
                Text(
                  getLocalizedContent(post),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Images section
          if (post.images != null && post.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildImagesSection(context),
          ],
          // Tags
          if (post.tags != null && post.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: post.tags.map<Widget>((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (post.upvotes > 0) ...[
                  Icon(
                    Icons.favorite,
                    size: 18,
                    color: Colors.red[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.upvotes}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                const Spacer(),
                if (post.totalComments > 0)
                  Text(
                    '${post.totalComments} تعليق',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Divider
          const Divider(height: 1, thickness: 1),
          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Like button
                _ActionButton(
                  icon: isLiked ? Icons.favorite : Icons.favorite_border,
                  label: 'أعجبني',
                  color: isLiked ? Colors.red : Colors.grey[700],
                  onPressed: onLike,
                ),
                // Comment button
                _ActionButton(
                  icon: Icons.mode_comment_outlined,
                  label: 'تعليق',
                  color: Colors.grey[700],
                  onPressed: onComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    final images = post.images as List;

    if (images.length == 1) {
      // Single image
      return GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 400),
          width: double.infinity,
          child: Image.network(
            images[0],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 200,
                color: Colors.grey[200],
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                    size: 50,
                  ),
                ),
              );
            },
          ),
        ),
      );
    } else if (images.length == 2) {
      // Two images side by side
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 250,
          child: Row(
            children: [
              Expanded(
                child: Image.network(
                  images[0],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Image.network(
                  images[1],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Grid for 3+ images
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 250,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Image.network(
                  images[0],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.broken_image, color: Colors.grey[400]),
                    );
                  },
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        images[1],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.broken_image, color: Colors.grey[400]),
                          );
                        },
                      ),
                    ),
                    if (images.length > 2) ...[
                      const SizedBox(height: 2),
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              images[2],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(Icons.broken_image, color: Colors.grey[400]),
                                );
                              },
                            ),
                            if (images.length > 3)
                              Container(
                                color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text(
                                    '+${images.length - 3}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}