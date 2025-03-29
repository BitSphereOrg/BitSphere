import 'package:flutter/material.dart';
import '../utils/colors.dart'; // Assuming you have a colors utility file

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const BottomNavigation({
    required this.selectedIndex,
    required this.onItemSelected,
    super.key,
  });

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
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemSelected,
          selectedItemColor: AppColors.accentYellow, // Use your color scheme
          unselectedItemColor: AppColors.secondaryText,
          backgroundColor: AppColors.primaryBackground,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Marketplace'),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 36),
              label: 'Upload',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Hosting'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}