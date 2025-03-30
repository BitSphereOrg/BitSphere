import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore
import '../utils/colors.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomNavigation({
    required this.selectedIndex,
    required this.onItemSelected,
    super.key,
  });

  Future<bool> _isDeveloper() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return false; // No user logged in

    final firestore = FirebaseFirestore.instance;
    final doc = await firestore.collection('users').doc(user.uid).get();
    return doc.exists && doc.data()?['role'] == 'developer';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: FutureBuilder<bool>(
          future: _isDeveloper(), // Check if the user is a developer
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading state while checking the user's role
              return BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Hosting'),
                  BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ],
                currentIndex: selectedIndex,
                onTap: null, // Disable taps during loading
                selectedItemColor: AppColors.accentYellow,
                unselectedItemColor: AppColors.secondaryText,
                backgroundColor: AppColors.primaryBackground,
              );
            }

            // Determine the items based on whether the user is a developer
            final isDeveloper = snapshot.data ?? false;
            final items = [
              const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              if (isDeveloper) // Only show Upload for developers
                const BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Upload'),
              const BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Hosting'),
              const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ];

            // Adjust selectedIndex if necessary (e.g., if Upload is hidden)
            int adjustedIndex = selectedIndex;
            if (!isDeveloper && selectedIndex > 1) {
              adjustedIndex--; // Shift index down if Upload is hidden
            } else if (adjustedIndex > items.length - 1) {
              adjustedIndex = 0; // Fallback to Home if index is out of bounds
            }

            return BottomNavigationBar(
              currentIndex: adjustedIndex,
              onTap: (index) {
                if (!isDeveloper && index > 0) {
                  onItemSelected(index + 1); // Adjust index for callback
                } else {
                  onItemSelected(index);
                }
              },
              selectedItemColor: AppColors.accentYellow,
              unselectedItemColor: AppColors.secondaryText,
              backgroundColor: AppColors.primaryBackground,
              items: items,
            );
          },
        ),
      ),
    );
  }
}