import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/news_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/raqim_app_bar.dart';

class NewsDetailsScreen extends StatefulWidget {
  final String newsId;

  const NewsDetailsScreen({super.key, required this.newsId});

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const RaqimAppBar(
        title: 'تفاصيل الخبر',
      ),
      body: Consumer<NewsProvider>(
        builder: (context, provider, child) {
          final article = provider.news.firstWhere(
            (n) => n.id == widget.newsId,
            orElse: () => provider.news.first,
          );

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Article Card
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Article Image
                            if (article.imageUrl != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 16 / 6,
                                  child: CachedNetworkImage(
                                    imageUrl: article.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(child: CircularProgressIndicator()),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image_not_supported, size: 50),
                                    ),
                                  ),
                                ),
                              ),

                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Article Title
                                  Text(
                                    _getLocalizedNewsTitle(article),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Article Meta Info
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.source,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          _getLocalizedSource(article),
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.schedule,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(article.publishedAt),
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Article Content
                                  Text(
                                    _getLocalizedNewsDescription(article),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.6,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Full Article Content (if available)
                                  if (article.content != null && article.content!.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          article.content!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.6,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                    ),

                                  // Category Tag
                                  if (article.category != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        article.category!,
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),

                                  // Interaction Buttons
                                  Row(
                                    children: [
                                      // Like Button
                                      InkWell(
                                        onTap: () {
                                          final authProvider = Provider.of<AuthProvider>(
                                            context,
                                            listen: false,
                                          );
                                          final userId = authProvider.currentUser?.id ?? 'guest';
                                          provider.toggleLike(article.id, userId);
                                        },
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: article.isLiked
                                                ? Colors.red.withValues(alpha: 0.1)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: article.isLiked
                                                  ? Colors.red.withValues(alpha: 0.3)
                                                  : Colors.grey.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                article.isLiked ? Icons.favorite : Icons.favorite_border,
                                                size: 18,
                                                color: article.isLiked ? Colors.red : Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                article.likesCount.toString(),
                                                style: TextStyle(
                                                  color: article.isLiked ? Colors.red : Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const Spacer(),

                                      // Comments Count
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.comment_outlined,
                                            size: 18,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${article.commentsCount} تعليق',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Comments Section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'التعليقات',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Comments List
                            if (article.comments?.isEmpty ?? true)
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.comment_outlined,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'لا توجد تعليقات بعد',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'كن أول من يعلق على هذا الخبر',
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...(article.comments ?? []).map((comment) => Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppColors.primaryColor,
                                          child: comment.authorAvatar != null
                                              ? ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl: comment.authorAvatar!,
                                                    width: 32,
                                                    height: 32,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Text(
                                                  comment.authorName.isNotEmpty
                                                      ? comment.authorName[0].toUpperCase()
                                                      : 'U',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                comment.authorName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                _formatCommentDate(comment.createdAt),
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      comment.content,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80), // Space for comment input
                    ],
                  ),
                ),
              ),

              // Comment Input
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'اكتب تعليقك...',
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _addComment(context, provider),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => _addComment(context, provider),
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addComment(BuildContext context, NewsProvider provider) async {
    if (_commentController.text.trim().isNotEmpty) {
      final text = _commentController.text.trim();
      _commentController.clear();

      await provider.addComment(widget.newsId, text, context);

      // Scroll to bottom to see new comment
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  String _getLocalizedNewsTitle(dynamic article) {
    switch (article.id) {
      case '1':
        return 'أحدث تطورات الذكاء الاصطناعي في عام 2024';
      case '2':
        return 'شركة OpenAI تطلق نموذج GPT-5 الجديد';
      case '3':
        return 'استثمارات ضخمة في تقنيات الذكاء الاصطناعي';
      case '4':
        return 'نقاش حول أخلاقيات الذكاء الاصطناعي';
      case '5':
        return 'تطبيقات الذكاء الاصطناعي في الطب';
      default:
        return article.title;
    }
  }

  String _getLocalizedNewsDescription(dynamic article) {
    switch (article.id) {
      case '1':
        return 'تشهد تقنيات الذكاء الاصطناعي تطورات مذهلة في عام 2024، حيث تم إطلاق العديد من النماذج والتطبيقات الجديدة التي تعيد تشكيل الطريقة التي نتفاعل بها مع التكنولوجيا. هذه التطورات تشمل نماذج لغوية أكثر تقدماً، وتطبيقات ذكية في مختلف المجالات، وحلول مبتكرة للتحديات اليومية.';
      case '2':
        return 'أعلنت شركة OpenAI عن إطلاق نموذجها الجديد GPT-5، والذي يتميز بقدرات محسّنة في فهم السياق والتفكير المنطقي. هذا النموذج يمثل نقلة نوعية في مجال الذكاء الاصطناعي ويقدم إمكانيات جديدة للمطورين والمستخدمين على حد سواء.';
      case '3':
        return 'شهد قطاع الذكاء الاصطناعي استثمارات قياسية تتجاوز 50 مليار دولار في العام الماضي، مما يؤكد على الثقة المتزايدة في إمكانيات هذه التقنيات وقدرتها على إحداث تغيير جذري في مختلف الصناعات.';
      case '4':
        return 'يناقش الخبراء والأكاديميون التحديات الأخلاقية المرتبطة بتطوير واستخدام تقنيات الذكاء الاصطناعي، مع التركيز على ضرورة وضع إطار أخلاقي واضح لضمان الاستخدام المسؤول لهذه التقنيات.';
      case '5':
        return 'تشهد تطبيقات الذكاء الاصطناعي في المجال الطبي نمواً متسارعاً، حيث تساعد في تشخيص الأمراض بدقة عالية وتطوير علاجات مخصصة، مما يحسن من جودة الرعاية الصحية ويقلل من التكاليف.';
      default:
        return article.description;
    }
  }

  String _getLocalizedSource(dynamic article) {
    switch (article.id) {
      case '1':
        return 'TechCrunch العربية';
      case '2':
        return 'Wired الشرق الأوسط';
      case '3':
        return 'Forbes العربية';
      case '4':
        return 'MIT Technology Review';
      case '5':
        return 'Nature الطبية';
      default:
        return article.source;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 30) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatCommentDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} د';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} س';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} ي';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}