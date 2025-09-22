import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/news_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;

    if (isWideScreen) {
      return _buildDesktopLayout(context, newsProvider);
    } else {
      return _buildMobileLayout(context, newsProvider);
    }
  }

  Widget _buildDesktopLayout(BuildContext context, NewsProvider newsProvider) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            'assets/images/raqimLogo.svg',
            height: 28,
            colorFilter: ColorFilter.mode(
              AppColors.primaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Text(
          'الأخبار',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: newsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar and categories
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Search bar
                      Container(
                        width: 400,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            newsProvider.searchNews(value);
                          },
                          decoration: InputDecoration(
                            hintText: 'ابحث عن الأخبار...',
                            hintStyle: AppTextStyles.small.copyWith(
                              color: Colors.grey[500],
                            ),
                            prefixIcon: const Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Categories as horizontal chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _buildHorizontalCategoryChips(newsProvider, context),
                        ),
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      child: newsProvider.news.isNotEmpty
                          ? _buildMainContent(context, newsProvider)
                          : const Center(
                              child: Text('لا توجد أخبار متاحة'),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, NewsProvider newsProvider) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            'assets/images/raqimLogo.svg',
            height: 28,
            colorFilter: ColorFilter.mode(
              AppColors.primaryColor,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Text(
          'الأخبار',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: newsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => newsProvider.refreshNews(),
              child: Column(
                children: [
                  // Categories at the top
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
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
                  // News list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: newsProvider.news.length,
                      itemBuilder: (context, index) {
                        final article = newsProvider.news[index];
                        return _buildMobileArticleCard(context, article, newsProvider);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, bool isActive, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive ? AppColors.primaryColor : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.body.copyWith(
              color: isActive ? AppColors.primaryColor : Colors.grey[700],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHorizontalCategoryChips(NewsProvider provider, BuildContext context) {
    final categories = [
      'الكل',
      'أبحاث جديدة',
      'منتجات وتطبيقات',
      'استثمارات وتمويل',
      'أخلاقيات الذكاء الاصطناعي'
    ];

    return categories.map((category) {
      final isSelected = provider.selectedCategory == category;
      return Container(
        margin: const EdgeInsets.only(right: 12),
        child: InkWell(
          onTap: () => provider.setCategory(category),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : const Color(0xFFE0E0E0),
                width: 1,
              ),
            ),
            child: Text(
              _getLocalizedCategory(category, context),
              style: AppTextStyles.small.copyWith(
                color: isSelected ? Colors.white : const Color(0xFF666666),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMainContent(BuildContext context, NewsProvider newsProvider) {
    // إذا كان هناك خبر محدد، نعرضه بدلاً من الخبر الأول
    final featuredArticle = newsProvider.selectedNews ?? newsProvider.news.first;
    final relatedNews = newsProvider.news.where((news) => news.id != featuredArticle.id).take(3).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured Article
        Expanded(
          flex: 2,
          child: _buildFeaturedArticle(context, featuredArticle, newsProvider),
        ),
        const SizedBox(width: 32),
        // Related News Sidebar
        Expanded(
          flex: 1,
          child: _buildRelatedNewsSidebar(context, relatedNews, newsProvider),
        ),
      ],
    );
  }

  Widget _buildMainContentFullWidth(BuildContext context, NewsProvider newsProvider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: newsProvider.news.length,
      itemBuilder: (context, index) {
        final article = newsProvider.news[index];
        return _buildNewsCard(context, article, newsProvider);
      },
    );
  }

  Widget _buildFeaturedArticle(BuildContext context, dynamic article, NewsProvider newsProvider) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              article.category ?? 'الكل',
              style: AppTextStyles.small.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Large Article image
          if (article.imageUrl != null)
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(article.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 20),
          // Article title (Large)
          Text(
            _getLocalizedNewsTitle(article, context),
            style: AppTextStyles.h1.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.2,
              fontSize: 32,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // Article description
          Text(
            _getLocalizedNewsDescription(article, context),
            style: AppTextStyles.body.copyWith(
              fontSize: 18,
              height: 1.6,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 20),
          // Author info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryColor,
                child: Text(
                  'ج',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _getLocalizedSource(article, context),
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 24),
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(article.publishedAt, context),
                style: AppTextStyles.small.copyWith(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Interaction buttons
          Row(
            children: [
              // Like Button
              InkWell(
                onTap: () {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final userId = authProvider.currentUser?.id ?? 'guest';
                  newsProvider.toggleLike(article.id, userId);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              const SizedBox(width: 16),
              // Comments Button
              InkWell(
                onTap: () => _showCommentsDialog(context, article, newsProvider),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedNewsSidebar(BuildContext context, List<dynamic> relatedNews, NewsProvider newsProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أخبار ذات صلة',
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...relatedNews.map((article) => _buildRelatedNewsCard(context, article, newsProvider)).toList(),
      ],
    );
  }

  Widget _buildRelatedNewsCard(BuildContext context, dynamic article, NewsProvider newsProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          newsProvider.selectNews(article.id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              Container(
                height: 120,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(
                    image: NetworkImage(article.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getLocalizedCategory('أبحاث جديدة', context),
                style: AppTextStyles.small.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getLocalizedNewsTitle(article, context),
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(article.publishedAt, context),
                  style: AppTextStyles.small.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileArticleCard(BuildContext context, dynamic article, NewsProvider newsProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          newsProvider.selectNews(article.id);
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedNewsTitle(article, context),
                    style: AppTextStyles.cardTitle.copyWith(
                      height: 1.3,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getLocalizedNewsDescription(article, context),
                    style: AppTextStyles.body.copyWith(
                      color: Colors.grey[600],
                      height: 1.4,
                      fontSize: 13,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getLocalizedSource(article, context),
                        style: AppTextStyles.small.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _formatDate(article.publishedAt, context),
                        style: AppTextStyles.small.copyWith(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          final userId = authProvider.currentUser?.id ?? 'guest_user';
                          newsProvider.toggleLike(article.id, userId);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                article.isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 20,
                                color: article.isLiked ? Colors.red : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${article.likesCount}',
                                style: AppTextStyles.small.copyWith(
                                  color: article.isLiked ? Colors.red : Colors.grey[600],
                                  fontSize: 12,
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
                                size: 20,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${article.commentsCount}',
                                style: AppTextStyles.small.copyWith(
                                  color: Colors.grey[600],
                                  fontSize: 12,
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
          ],
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
                child: Consumer<NewsProvider>(
                  builder: (context, newsProvider, child) {
                    final currentArticle = newsProvider.news.firstWhere((n) => n.id == article.id, orElse: () => article);
                    return currentArticle.comments?.isNotEmpty == true
                        ? ListView.builder(
                            controller: scrollController,
                            itemCount: currentArticle.comments!.length,
                            itemBuilder: (context, index) {
                              final comment = currentArticle.comments![index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Consumer<AuthProvider>(
                                      builder: (context, authProvider, child) {
                                        final currentUser = authProvider.currentUser;
                                        final isCurrentUserComment = currentUser != null &&
                                            comment.authorName == currentUser.name;

                                        final photoUrl = isCurrentUserComment && currentUser.photoUrl != null
                                            ? currentUser.photoUrl
                                            : comment.authorAvatar;

                                        return CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Colors.grey[300],
                                          child: photoUrl != null
                                              ? ClipOval(child: Image.network(photoUrl!))
                                              : Text(comment.authorName[0].toUpperCase()),
                                        );
                                      },
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
                          );
                  },
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
                      onPressed: () async {
                        if (commentController.text.trim().isNotEmpty) {
                          final text = commentController.text.trim();
                          commentController.clear();
                          await provider.addComment(article.id, text, context);
                          // Scroll to top to see the new comment
                          if (scrollController.hasClients) {
                            scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          }
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

  Widget _buildNewsCard(BuildContext context, dynamic article, NewsProvider newsProvider) {
    return Container(
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
      child: InkWell(
        onTap: () {
          newsProvider.selectNews(article.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article image
            if (article.imageUrl != null)
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: DecorationImage(
                    image: NetworkImage(article.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // Article content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getLocalizedCategory('أبحاث جديدة', context),
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      _getLocalizedNewsTitle(article, context),
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(article.publishedAt, context),
                          style: AppTextStyles.small.copyWith(
                            color: Colors.grey[600],
                            fontSize: 12,
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
  }
}