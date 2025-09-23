import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/raqim_app_bar.dart';
import '../models/ai_tool_model.dart';

class AIToolsScreen extends StatefulWidget {
  const AIToolsScreen({super.key});

  @override
  State<AIToolsScreen> createState() => _AIToolsScreenState();
}

class _AIToolsScreenState extends State<AIToolsScreen> {
  String _selectedCategory = 'الكل';

  final List<String> _categories = [
    'الكل',
    'معالجة النصوص',
    'الصور والرسوم',
    'الفيديو والصوت',
    'التطوير والبرمجة',
    'التحليل والبيانات',
    'الإنتاجية',
  ];

  final List<AITool> _aiTools = [
    // Text Processing Tools
    AITool(
      id: '1',
      name: 'ChatGPT',
      description: 'نموذج ذكي للمحادثة وإنشاء النصوص',
      category: 'معالجة النصوص',
      iconData: Icons.chat,
      color: const Color(0xFF10A37F),
      url: 'https://chat.openai.com',
      isPopular: true,
      imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/0/04/ChatGPT_logo.svg',
    ),
    AITool(
      id: '2',
      name: 'Claude',
      description: 'مساعد ذكي للمحادثة والتحليل',
      category: 'معالجة النصوص',
      iconData: Icons.psychology,
      color: const Color(0xFFD97706),
      url: 'https://claude.ai',
      isPopular: true,
      imageUrl: 'https://images.crunchbase.com/image/upload/c_lpad,f_auto,q_auto:eco,dpr_1/erkxwhl1gd48xfhe2yld',
    ),
    AITool(
      id: '3',
      name: 'Jasper AI',
      description: 'أداة لإنشاء المحتوى التسويقي',
      category: 'معالجة النصوص',
      iconData: Icons.edit,
      color: const Color(0xFF8B5CF6),
      url: 'https://jasper.ai',
    ),
    AITool(
      id: '4',
      name: 'Copy.ai',
      description: 'مولد النصوص التسويقية',
      category: 'معالجة النصوص',
      iconData: Icons.content_copy,
      color: const Color(0xFF06B6D4),
      url: 'https://copy.ai',
    ),

    // Image & Design Tools
    AITool(
      id: '5',
      name: 'Midjourney',
      description: 'إنشاء الصور بالذكاء الاصطناعي',
      category: 'الصور والرسوم',
      iconData: Icons.palette,
      color: const Color(0xFFEC4899),
      url: 'https://midjourney.com',
      isPopular: true,
      imageUrl: 'https://cdn.mos.cms.futurecdn.net/4RQkcpWVfJF4VSdLCFWNUK.jpg',
    ),
    AITool(
      id: '6',
      name: 'DALL-E 3',
      description: 'مولد الصور من النصوص',
      category: 'الصور والرسوم',
      iconData: Icons.image,
      color: const Color(0xFF059669),
      url: 'https://openai.com/dall-e-3',
      isPopular: true,
    ),
    AITool(
      id: '7',
      name: 'Stable Diffusion',
      description: 'نموذج مفتوح لإنشاء الصور',
      category: 'الصور والرسوم',
      iconData: Icons.auto_awesome,
      color: const Color(0xFF7C3AED),
      url: 'https://stability.ai',
    ),
    AITool(
      id: '8',
      name: 'Canva AI',
      description: 'أدوات التصميم بالذكاء الاصطناعي',
      category: 'الصور والرسوم',
      iconData: Icons.design_services,
      color: const Color(0xFF00C4CC),
      url: 'https://canva.com',
    ),

    // Video & Audio Tools
    AITool(
      id: '9',
      name: 'Runway ML',
      description: 'إنشاء وتحرير الفيديو بالذكاء الاصطناعي',
      category: 'الفيديو والصوت',
      iconData: Icons.movie,
      color: const Color(0xFFEF4444),
      url: 'https://runwayml.com',
      isPopular: true,
    ),
    AITool(
      id: '10',
      name: 'ElevenLabs',
      description: 'تحويل النص إلى صوت طبيعي',
      category: 'الفيديو والصوت',
      iconData: Icons.record_voice_over,
      color: const Color(0xFF6366F1),
      url: 'https://elevenlabs.io',
    ),
    AITool(
      id: '11',
      name: 'Synthesia',
      description: 'إنشاء فيديو بشخصيات افتراضية',
      category: 'الفيديو والصوت',
      iconData: Icons.play_arrow,
      color: const Color(0xFFF59E0B),
      url: 'https://synthesia.io',
    ),

    // Development & Programming
    AITool(
      id: '12',
      name: 'GitHub Copilot',
      description: 'مساعد البرمجة الذكي',
      category: 'التطوير والبرمجة',
      iconData: Icons.code,
      color: const Color(0xFF181717),
      url: 'https://github.com/features/copilot',
      isPopular: true,
      imageUrl: 'https://github.githubassets.com/images/modules/site/copilot/copilot.png',
    ),
    AITool(
      id: '13',
      name: 'Cursor',
      description: 'محرر الأكواد بالذكاء الاصطناعي',
      category: 'التطوير والبرمجة',
      iconData: Icons.terminal,
      color: const Color(0xFF000000),
      url: 'https://cursor.sh',
    ),
    AITool(
      id: '14',
      name: 'Replit AI',
      description: 'منصة البرمجة التفاعلية',
      category: 'التطوير والبرمجة',
      iconData: Icons.memory,
      color: const Color(0xFF0099FF),
      url: 'https://replit.com',
    ),

    // Analytics & Data
    AITool(
      id: '15',
      name: 'Tableau AI',
      description: 'تحليل البيانات وإنشاء التقارير',
      category: 'التحليل والبيانات',
      iconData: Icons.analytics,
      color: const Color(0xFFE97627),
      url: 'https://tableau.com',
    ),
    AITool(
      id: '16',
      name: 'DataRobot',
      description: 'منصة تعلم الآلة المؤتمتة',
      category: 'التحليل والبيانات',
      iconData: Icons.smart_toy,
      color: const Color(0xFF00D4AA),
      url: 'https://datarobot.com',
    ),

    // Productivity Tools
    AITool(
      id: '17',
      name: 'Notion AI',
      description: 'مساعد الكتابة والتنظيم',
      category: 'الإنتاجية',
      iconData: Icons.note,
      color: const Color(0xFF000000),
      url: 'https://notion.so',
    ),
    AITool(
      id: '18',
      name: 'Grammarly',
      description: 'مدقق النحو والإملاء الذكي',
      category: 'الإنتاجية',
      iconData: Icons.spellcheck,
      color: const Color(0xFF15C39A),
      url: 'https://grammarly.com',
    ),
    AITool(
      id: '19',
      name: 'Otter.ai',
      description: 'تحويل الصوت إلى نص',
      category: 'الإنتاجية',
      iconData: Icons.transcribe,
      color: const Color(0xFF00B8D4),
      url: 'https://otter.ai',
    ),
    AITool(
      id: '20',
      name: 'Calendly AI',
      description: 'جدولة الاجتماعات الذكية',
      category: 'الإنتاجية',
      iconData: Icons.event,
      color: const Color(0xFF006BFF),
      url: 'https://calendly.com',
    ),
  ];

  List<AITool> get filteredTools {
    if (_selectedCategory == 'الكل') {
      return _aiTools;
    }
    return _aiTools.where((tool) => tool.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RaqimAppBar(
        title: 'أدوات الذكاء الاصطناعي',
        showLogo: false,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Categories Filter
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: AppColors.primaryColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primaryColor : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // Tools Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: filteredTools.length,
                itemBuilder: (context, index) {
                  final tool = filteredTools[index];
                  return AIToolCard(
                    tool: tool,
                    onTap: () => _openTool(tool),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openTool(AITool tool) async {
    // Show a dialog with tool info and open URL option
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tool.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                tool.iconData,
                color: tool.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tool.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tool.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: tool.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tool.category,
                style: TextStyle(
                  color: tool.color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _launchUrl(tool.url, tool.name);
            },
            style: ElevatedButton.styleFrom(backgroundColor: tool.color),
            child: const Text('افتح الأداة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url, String toolName) async {
    try {
      final Uri uri = Uri.parse(url);
      // Try external application first, then browser if that fails
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
      }
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لا يمكن فتح رابط $toolName'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في فتح رابط $toolName'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class AIToolCard extends StatelessWidget {
  final AITool tool;
  final VoidCallback onTap;

  const AIToolCard({
    super.key,
    required this.tool,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon/image and popular badge
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: tool.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: tool.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              tool.imageUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  tool.iconData,
                                  color: tool.color,
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : Icon(
                            tool.iconData,
                            color: tool.color,
                            size: 24,
                          ),
                  ),
                  const Spacer(),
                  if (tool.isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'شائع',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tool.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: tool.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tool.category,
                        style: TextStyle(
                          color: tool.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom padding
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}