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
}