import 'package:flutter/material.dart';
import '../utils/colors.dart';

class ContainerBase extends StatelessWidget {
  final String category;

  const ContainerBase({required this.category, super.key});

  @override
  Widget build(BuildContext context) {
    final projects = List.generate(10, (index) => 'Bit Project $index in $category');

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return Card(
          color: AppColors.secondaryBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          margin: const EdgeInsets.only(bottom: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projects[index],
                  style: const TextStyle(color: AppColors.primaryText, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'Description of whole project in short & ${projects[index]}',
                  style: const TextStyle(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}