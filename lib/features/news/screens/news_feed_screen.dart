import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/news_provider.dart';
import '../../../core/localization/app_localizations.dart';

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({super.key});
  
  String _getLocalizedCategory(String category, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    switch (category) {
      case 'الكل':
        return localizations?.translate('newsAll') ?? category;
      case 'أبحاث جديدة':
        return localizations?.translate('newResearch') ?? category;
      case 'منتجات وتطبيقات':
        return localizations?.translate('productsApplications') ?? category;
      case 'استثمارات وتمويل':
        return localizations?.translate('investmentFunding') ?? category;
      case 'أخلاقيات الذكاء الاصطناعي':
        return localizations?.translate('aiEthics') ?? category;
      default:
        return category;
    }
  }
  
  String _getLocalizedNewsTitle(dynamic article, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    switch (article.id) {
      case '1':
        return localizations?.translate('newsArticle1Title') ?? article.title;
      case '2':
        return localizations?.translate('newsArticle2Title') ?? article.title;
      case '3':
        return localizations?.translate('newsArticle3Title') ?? article.title;
      case '4':
        return localizations?.translate('newsArticle4Title') ?? article.title;
      case '5':
        return localizations?.translate('newsArticle5Title') ?? article.title;
      default:
        return article.title;
    }
  }
  
  String _getLocalizedNewsDescription(dynamic article, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    switch (article.id) {
      case '1':
        return localizations?.translate('newsArticle1Description') ?? article.description;
      case '2':
        return localizations?.translate('newsArticle2Description') ?? article.description;
      case '3':
        return localizations?.translate('newsArticle3Description') ?? article.description;
      case '4':
        return localizations?.translate('newsArticle4Description') ?? article.description;
      case '5':
        return localizations?.translate('newsArticle5Description') ?? article.description;
      default:
        return article.description;
    }
  }
  
  String _getLocalizedSource(dynamic article, BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    switch (article.id) {
      case '1':
        return localizations?.translate('newsSource1') ?? article.source;
      case '2':
        return localizations?.translate('newsSource2') ?? article.source;
      case '3':
        return localizations?.translate('newsSource3') ?? article.source;
      case '4':
        return localizations?.translate('newsSource4') ?? article.source;
      case '5':
        return localizations?.translate('newsSource5') ?? article.source;
      default:
        return article.source;
    }
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('newsTitle') ?? 'الأخبار'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildCategoryChip('الكل', newsProvider, context),
                _buildCategoryChip('أبحاث جديدة', newsProvider, context),
                _buildCategoryChip('منتجات وتطبيقات', newsProvider, context),
                _buildCategoryChip('استثمارات وتمويل', newsProvider, context),
                _buildCategoryChip('أخلاقيات الذكاء الاصطناعي', newsProvider, context),
              ],
            ),
          ),
        ),
      ),
      body: newsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => newsProvider.refreshNews(),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWideScreen ? 3 : 1,
                  childAspectRatio: isWideScreen ? 0.95 : 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: newsProvider.news.length,
                itemBuilder: (context, index) {
                  final article = newsProvider.news[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () async {
                        final uri = Uri.parse(article.url);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (article.imageUrl != null)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: CachedNetworkImage(
                                imageUrl: article.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      _getLocalizedNewsTitle(article, context),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        height: 1.1,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Flexible(
                                    child: Text(
                                      _getLocalizedNewsDescription(article, context),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        height: 1.2,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          _getLocalizedSource(article, context),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          _formatDate(article.publishedAt, context),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey[600],
                                            fontSize: 10,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Like and Comment buttons
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () => newsProvider.toggleLike(article.id),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                article.isLiked ? Icons.favorite : Icons.favorite_border,
                                                size: 16,
                                                color: article.isLiked ? Colors.red : Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${article.likesCount}',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontSize: 10,
                                                  color: article.isLiked ? Colors.red : Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      InkWell(
                                        onTap: () => _showCommentsDialog(context, article, newsProvider),
                                        borderRadius: BorderRadius.circular(20),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.comment_outlined,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${article.commentsCount}',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontSize: 10,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildCategoryChip(String category, NewsProvider provider, BuildContext context) {
    final isSelected = provider.selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(_getLocalizedCategory(category, context)),
        selected: isSelected,
        onSelected: (_) => provider.setCategory(category),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(date);
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
    } else {
      final minuteText = localizations?.translate('minutesAgo') ?? 'دقائق';
      return '${localizations?.translate('since') ?? 'منذ'} ${diff.inMinutes} $minuteText';
    }
  }

  void _showCommentsDialog(BuildContext context, dynamic article, NewsProvider provider) {
    final TextEditingController commentController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.comment_outlined),
                    const SizedBox(width: 8),
                    Text(
                      'التعليقات (${article.commentsCount})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Comments list
              Expanded(
                child: article.comments?.isNotEmpty == true
                    ? ListView.builder(
                        controller: scrollController,
                        itemCount: article.comments!.length,
                        itemBuilder: (context, index) {
                          final comment = article.comments![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Colors.grey[300],
                                  child: comment.authorAvatar != null 
                                      ? ClipOval(child: Image.network(comment.authorAvatar!))
                                      : Text(comment.authorName[0].toUpperCase()),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            comment.authorName,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatDate(comment.createdAt, context),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment.content,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.comment_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد تعليقات بعد',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'كن أول من يعلق على هذا الخبر',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              
              // Comment input
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'اكتب تعليقك هنا...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        if (commentController.text.trim().isNotEmpty) {
                          provider.addComment(article.id, commentController.text.trim());
                          commentController.clear();
                        }
                      },
                      icon: const Icon(Icons.send),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}