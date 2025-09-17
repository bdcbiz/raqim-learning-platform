import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: AppColors.primaryColor,
      child: Column(
        children: [
          // Logo/Header
          Container(
            height: 120,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'لوحة التحكم',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24, height: 1),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildMenuItem(
                  index: 0,
                  icon: Icons.dashboard,
                  title: 'لوحة القيادة',
                  isSelected: selectedIndex == 0,
                  onTap: () => onItemSelected(0),
                ),
                _buildMenuItem(
                  index: 1,
                  icon: Icons.school,
                  title: 'إدارة الدورات',
                  isSelected: selectedIndex == 1,
                  onTap: () => onItemSelected(1),
                ),
                _buildMenuItem(
                  index: 2,
                  icon: Icons.people,
                  title: 'إدارة المستخدمين',
                  isSelected: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                ),
                _buildMenuItem(
                  index: 3,
                  icon: Icons.article,
                  title: 'إدارة المحتوى',
                  isSelected: selectedIndex == 3,
                  onTap: () => onItemSelected(3),
                  hasSubmenu: true,
                ),
                if (selectedIndex == 3) ...[
                  _buildSubMenuItem(
                    icon: Icons.newspaper,
                    title: 'الأخبار',
                    onTap: () {},
                  ),
                  _buildSubMenuItem(
                    icon: Icons.category,
                    title: 'التصنيفات',
                    onTap: () {},
                  ),
                  _buildSubMenuItem(
                    icon: Icons.ads_click,
                    title: 'الإعلانات',
                    onTap: () {},
                  ),
                ],
                _buildMenuItem(
                  index: 4,
                  icon: Icons.attach_money,
                  title: 'الإدارة المالية',
                  isSelected: selectedIndex == 4,
                  onTap: () => onItemSelected(4),
                  hasSubmenu: true,
                ),
                if (selectedIndex == 4) ...[
                  _buildSubMenuItem(
                    icon: Icons.receipt,
                    title: 'المعاملات',
                    onTap: () {},
                  ),
                  _buildSubMenuItem(
                    icon: Icons.verified,
                    title: 'التحقق اليدوي',
                    onTap: () {},
                  ),
                ],
                _buildMenuItem(
                  index: 5,
                  icon: Icons.settings,
                  title: 'الإعدادات',
                  isSelected: selectedIndex == 5,
                  onTap: () => onItemSelected(5),
                ),
              ],
            ),
          ),

          // Logout
          const Divider(color: Colors.white24, height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              // Handle logout
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool hasSubmenu = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: hasSubmenu
            ? Icon(
                isSelected ? Icons.expand_less : Icons.expand_more,
                color: Colors.white70,
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSubMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 40, right: 12, top: 4, bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.white54, size: 20),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}