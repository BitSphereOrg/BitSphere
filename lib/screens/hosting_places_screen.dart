import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/heroku_service.dart';

class HostingPlacesScreen extends StatelessWidget {
  const HostingPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final herokuService = HerokuService();

    return Scaffold(
      body: user == null
          ? const Center(child: Text('Please sign in to view hosting places.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('services')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No services to host.',
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                  );
                }

                final services = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index].data() as Map<String, dynamic>;
                    final serviceId = services[index].id;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('projects')
                          .doc(service['projectId'])
                          .get(),
                      builder: (context, projectSnapshot) {
                        if (projectSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!projectSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final project = projectSnapshot.data!.data() as Map<String, dynamic>;
                        final githubUrl = project['githubUrl'] as String;
                        final appName = 'bitsphere-$serviceId';

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
                                  service['projectName'],
                                  style: const TextStyle(
                                    color: AppColors.primaryText,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      final appId = await herokuService.createApp(appName);
                                      await herokuService.deployApp(appId, githubUrl);
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .collection('services')
                                          .doc(serviceId)
                                          .update({
                                        'herokuAppId': appId,
                                        'herokuAppName': appName,
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Deployed to Heroku!')),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Deployment failed: $e')),
                                      );
                                    }
                                  },
                                  child: const Text('Deploy to Heroku'),
                                ),
                                const SizedBox(height: 8),
                                FutureBuilder<bool>(
                                  future: service['herokuAppId'] != null
                                      ? herokuService.getAppStatus(service['herokuAppId'])
                                      : Future.value(false),
                                  builder: (context, statusSnapshot) {
                                    if (statusSnapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }
                                    final isRunning = statusSnapshot.data ?? false;

                                    return Row(
                                      children: [
                                        Text(
                                          'Status: ${isRunning ? 'On' : 'Off'}',
                                          style: const TextStyle(color: AppColors.primaryText),
                                        ),
                                        const SizedBox(width: 16),
                                        Switch(
                                          value: isRunning,
                                          onChanged: (value) async {
                                            if (service['herokuAppId'] != null) {
                                              await herokuService.toggleApp(service['herokuAppId'], value);
                                              (context as Element).markNeedsBuild();
                                            }
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}