import 'package:flutter/material.dart';
import '../utils/colors.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Marketplace Screen', style: TextStyle(color: AppColors.primaryText)),
    );
  }
}