import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'cart_screen.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('projects').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No projects available.', style: TextStyle(color: AppColors.primaryText)),
          );
        }

        final projects = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index].data() as Map<String, dynamic>;
            final projectId = projects[index].id;

            return Card(
              color: AppColors.secondaryBackground,
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['name'],
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Developer: ${project['developerName']}',
                      style: const TextStyle(color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project['description'],
                      style: const TextStyle(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      project['isPaid']
                          ? 'Price: \$${project['price']}'
                          : 'Free',
                      style: const TextStyle(color: AppColors.accentYellow),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          if (project['isPaid']) {
                            // Navigate to cart for paid projects
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartScreen(project: project, projectId: projectId),
                              ),
                            );
                          } else {
                            // Add to My Services directly for free projects
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('services')
                                .add({
                              'projectId': projectId,
                              'projectName': project['name'],
                              'addedAt': FieldValue.serverTimestamp(),
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to My Services!')),
                            );
                          }
                        }
                      },
                      child: const Text('Use It'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}