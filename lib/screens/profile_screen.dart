import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore
import '../utils/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Helper method to fetch user role from Firestore
  Future<String> _getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Not logged in';

    final firestore = FirebaseFirestore.instance;
    final doc = await firestore.collection('users').doc(user.uid).get();
    return doc.exists && doc.data() != null ? (doc.data()!['role'] ?? 'user') : 'user'; // Default to 'user' if no role
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login'); // Adjust route as needed
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 50, color: AppColors.secondaryText)
                  : null,
            ),
            const SizedBox(height: 16),

            // Display Name
            Text(
              user?.displayName ?? 'Anonymous',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              user?.email ?? 'No email provided',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),

            // Role Display
            FutureBuilder<String>(
              future: _getUserRole(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(
                    color: AppColors.accentYellow,
                  );
                }
                final role = snapshot.data ?? 'user';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: role == 'developer'
                        ? AppColors.accentYellow.withOpacity(0.2)
                        : AppColors.secondaryText.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Role: ${role[0].toUpperCase()}${role.substring(1)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: role == 'developer'
                          ? AppColors.accentYellow
                          : AppColors.secondaryText,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Developer-Specific Section (visible only to developers)
            FutureBuilder<String>(
              future: _getUserRole(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                final role = snapshot.data ?? 'user';
                if (role != 'developer') return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Developer Tools',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.code, color: AppColors.accentYellow),
                      title: const Text(
                        'API Keys',
                        style: TextStyle(color: AppColors.primaryText),
                      ),
                      onTap: () {
                        // Navigate to API Keys screen or show dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('API Keys feature coming soon!')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.analytics, color: AppColors.accentYellow),
                      title: const Text(
                        'Analytics Dashboard',
                        style: TextStyle(color: AppColors.primaryText),
                      ),
                      onTap: () {
                        // Navigate to Analytics screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Analytics feature coming soon!')),
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            // General User Actions
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to Edit Profile screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Profile feature coming soon!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 16, color: AppColors.primaryBackground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}