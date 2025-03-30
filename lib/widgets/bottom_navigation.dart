import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/colors.dart';
import '../utils/auth_service.dart'; 

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final AuthService authService;

  const BottomNavigation({
    required this.selectedIndex,
    required this.onItemSelected,
    required this.authService, 
    super.key,
  });

  // Stream to listen to auth state changes
  Stream<User?> get _authStateStream => FirebaseAuth.instance.authStateChanges();

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
        child: StreamBuilder<User?>(
          stream: _authStateStream, // Listen to auth state changes
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingNavBar();
            }

            final user = authSnapshot.data;
            if (user == null) {
              return _buildDefaultNavBar(); // Show basic nav for unauthenticated users
            }

            return FutureBuilder<String?>(
              future: authService.getUserRole(), // Fetch role once user is authenticated
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingNavBar();
                }

                final isDeveloper = roleSnapshot.data == 'developer';
                final items = [
                  const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                  if (isDeveloper) // Only show Upload for developers
                    const BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Upload'),
                  const BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Hosting'),
                  const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                ];

                // Adjust selectedIndex based on whether Upload is present
                int adjustedIndex = selectedIndex;
                if (!isDeveloper && selectedIndex > 1) {
                  adjustedIndex--; // Shift index down if Upload is hidden
                } else if (adjustedIndex >= items.length) {
                  adjustedIndex = 0; // Fallback to Home if out of bounds
                }

                return BottomNavigationBar(
                  currentIndex: adjustedIndex,
                  onTap: (index) {
                    // Adjust the index sent to the callback based on Upload's presence
                    if (!isDeveloper && index > 0) {
                      onItemSelected(index + 1);
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
            );
          },
        ),
      ),
    );
  }

  // Default navigation bar for unauthenticated users or loading state
  Widget _buildDefaultNavBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Hosting'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: selectedIndex.clamp(0, 2), // Clamp to valid range
      onTap: onItemSelected,
      selectedItemColor: AppColors.accentYellow,
      unselectedItemColor: AppColors.secondaryText,
      backgroundColor: AppColors.primaryBackground,
    );
  }

  // Loading state navigation bar
  Widget _buildLoadingNavBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Hosting'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: selectedIndex.clamp(0, 2), // Clamp to valid range
      onTap: null, // Disable taps during loading
      selectedItemColor: AppColors.accentYellow,
      unselectedItemColor: AppColors.secondaryText,
      backgroundColor: AppColors.primaryBackground,
    );
  }
}