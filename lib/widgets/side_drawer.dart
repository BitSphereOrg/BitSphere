import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/auth_service.dart';
import '../utils/colors.dart';
import 'my_services_screen.dart';

class SideDrawer extends StatefulWidget {
  final Function(int) onItemSelected;

  const SideDrawer({required this.onItemSelected, super.key});

  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  User? user = FirebaseAuth.instance.currentUser;
  final authService = AuthService();
  String name = "Loading...";
  String email = "Loading...";
  String photoUrl = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      setState(() {
        email = user!.email ?? "No email";
        photoUrl = user!.photoURL ?? "";
      });

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          name = userDoc['name'] ?? "No name";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              name,
              style: const TextStyle(color: AppColors.primaryText),
            ),
            accountEmail: Text(
              email,
              style: const TextStyle(color: AppColors.secondaryText),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
              backgroundColor: AppColors.accentBlue,
              child: photoUrl.isEmpty
                  ? const Icon(Icons.person,
                      size: 50, color: AppColors.primaryText)
                  : null,
            ),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16.0),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          _buildDrawerItem(context,
              icon: Icons.home,
              title: 'Home',
              onTap: () => widget.onItemSelected(0)),
          _buildDrawerItem(context,
              icon: Icons.add_circle,
              title: 'Upload',
              onTap: () => widget.onItemSelected(1)),
          _buildDrawerItem(context,
              icon: Icons.cloud,
              title: 'Hosting Places',
              onTap: () => widget.onItemSelected(2)),
          _buildDrawerItem(context,
              icon: Icons.person,
              title: 'Profile',
              onTap: () => widget.onItemSelected(3)),
          const Divider(color: AppColors.secondaryText),
          _buildDrawerItem(context, icon: Icons.build, title: 'My Services',
              onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyServicesScreen()),
            );
          }),
          _buildDrawerItem(context,
              icon: Icons.upload,
              title: 'My Uploads',
              onTap: () => print('Navigate to My Uploads')),
          const Divider(color: AppColors.secondaryText),
          _buildDrawerItem(context, icon: Icons.settings, title: 'Settings',
              onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Coming Soon!'),
              ),
            );
          }),
          _buildDrawerItem(context,
              icon: Icons.info,
              title: 'About',
              onTap: () => print('Navigate to About')),
          _buildDrawerItem(context, icon: Icons.logout, title: 'Logout',
              onTap: () async {
            await authService.signOut();
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
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
        title:
            Text(title, style: const TextStyle(color: AppColors.primaryText)),
        onTap: onTap,
      ),
    );
  }
}
