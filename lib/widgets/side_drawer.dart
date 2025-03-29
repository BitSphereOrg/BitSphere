import 'package:flutter/material.dart';
import '../utils/colors.dart';

class SideDrawer extends StatelessWidget {
  final Function(int) onItemSelected;

  const SideDrawer({required this.onItemSelected, super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16.0), // Add padding around the ListView
        children: [
          // Drawer header with profile photo
          UserAccountsDrawerHeader(
            accountName: const Text(
              'Silent',
              style: TextStyle(color: AppColors.primaryText),
            ),
            accountEmail: const Text(
              'silent@example.com',
              style: TextStyle(color: AppColors.secondaryText),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.accentBlue,
              child: const Icon(
                Icons.person,
                size: 50,
                color: AppColors.primaryText,
              ),
            ),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16.0),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          // Main navigation items
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Home',
            onTap: () {
              onItemSelected(0);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.shop,
            title: 'Marketplace',
            onTap: () {
              onItemSelected(1);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.add_circle,
            title: 'Upload',
            onTap: () {
              onItemSelected(2);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.cloud,
            title: 'Hosting Places',
            onTap: () {
              onItemSelected(3);
              Navigator.pop(context);
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person,
            title: 'Profile',
            onTap: () {
              onItemSelected(4);
              Navigator.pop(context);
            },
          ),
          const Divider(color: AppColors.secondaryText),
          // User-specific items
          _buildDrawerItem(
            context,
            icon: Icons.build,
            title: 'My Services',
            onTap: () {
              Navigator.pop(context);
              print('Navigate to My Services');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.chat,
            title: 'My Chats',
            onTap: () {
              Navigator.pop(context);
              print('Navigate to My Chats');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.upload,
            title: 'My Uploads',
            onTap: () {
              Navigator.pop(context);
              print('Navigate to My Uploads');
            },
          ),
          const Divider(color: AppColors.secondaryText),
          // Settings and About
          _buildDrawerItem(
            context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              print('Navigate to Settings');
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.info,
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              print('Navigate to About');
            },
          ),
          const Divider(color: AppColors.secondaryText),
          // Logout
          _buildDrawerItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              Navigator.pop(context);
              print('Logout');
            },
          ),
        ],
      ),
    );
  }

  // Helper method to build drawer items with box format and shadow
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.accentBlue),
        title: Text(
          title,
          style: const TextStyle(color: AppColors.primaryText),
        ),
        onTap: onTap,
      ),
    );
  }
}