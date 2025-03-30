import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/auth_service.dart';
import '../utils/colors.dart';
import 'my_services_screen.dart';

class SideDrawer extends StatelessWidget {
  final Function(int) onItemSelected;
  final AuthService authService;

  const SideDrawer({
    required this.onItemSelected,
    required this.authService, // Require AuthService instance
    super.key,
  });

  // Stream to listen to auth state changes
  Stream<User?> get _authStateStream => FirebaseAuth.instance.authStateChanges();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: StreamBuilder<User?>(
        stream: _authStateStream,
        builder: (context, authSnapshot) {
          final user = authSnapshot.data;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeader(context, user),
              const SizedBox(height: 8.0),
              _buildDrawerItem(
                context,
                icon: Icons.home,
                title: 'Home',
                onTap: () => onItemSelected(0),
              ),
              FutureBuilder<String?>(
                future: authService.getUserRole(),
                builder: (context, roleSnapshot) {
                  final isDeveloper = roleSnapshot.data == 'developer';
                  if (!isDeveloper) return const SizedBox.shrink();

                  return _buildDrawerItem(
                    context,
                    icon: Icons.add_circle,
                    title: 'Upload',
                    onTap: () => onItemSelected(1),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.cloud,
                title: 'Hosting Places',
                onTap: () => onItemSelected(2),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.person,
                title: 'Profile',
                onTap: () => onItemSelected(3),
              ),
              const Divider(color: AppColors.secondaryText),
              _buildDrawerItem(
                context,
                icon: Icons.build,
                title: 'My Services',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyServicesScreen()),
                  );
                },
              ),
              FutureBuilder<String?>(
                future: authService.getUserRole(),
                builder: (context, roleSnapshot) {
                  final isDeveloper = roleSnapshot.data == 'developer';
                  if (!isDeveloper) return const SizedBox.shrink();

                  return _buildDrawerItem(
                    context,
                    icon: Icons.upload,
                    title: 'My Uploads',
                    onTap: () => print('Navigate to My Uploads'),
                  );
                },
              ),
              const Divider(color: AppColors.secondaryText),
              _buildDrawerItem(
                context,
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming Soon!')),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.info,
                title: 'About',
                onTap: () => print('Navigate to About'),
              ),
              if (user != null) // Show Logout only if signed in
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () async {
                    await authService.signOut();
                    Navigator.pop(context); // Close drawer after logout
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    if (user == null) {
      return const UserAccountsDrawerHeader(
        accountName: Text('Guest', style: TextStyle(color: AppColors.primaryText)),
        accountEmail: Text('Not signed in', style: TextStyle(color: AppColors.secondaryText)),
        currentAccountPicture: CircleAvatar(
          backgroundColor: AppColors.accentBlue,
          child: Icon(Icons.person, size: 50, color: AppColors.primaryText),
        ),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
        ),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        String name = user.displayName ?? 'No name';
        String email = user.email ?? 'No email';
        String photoUrl = user.photoURL ?? '';

        if (snapshot.hasData && snapshot.data!.exists) {
          name = snapshot.data!['displayName'] ?? name; // Use 'displayName' to match AuthService
        }

        return UserAccountsDrawerHeader(
          accountName: Text(name, style: const TextStyle(color: AppColors.primaryText)),
          accountEmail: Text(email, style: const TextStyle(color: AppColors.secondaryText)),
          currentAccountPicture: CircleAvatar(
            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            backgroundColor: AppColors.accentBlue,
            child: photoUrl.isEmpty
                ? const Icon(Icons.person, size: 50, color: AppColors.primaryText)
                : null,
          ),
          decoration: const BoxDecoration(
            color: AppColors.secondaryBackground,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
          ),
        );
      },
    );
  }

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
        title: Text(title, style: const TextStyle(color: AppColors.primaryText)),
        onTap: () {
          Navigator.pop(context); // Close drawer on tap
          onTap();
        },
      ),
    );
  }
}