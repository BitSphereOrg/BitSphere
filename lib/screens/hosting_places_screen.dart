import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/heroku_service.dart';

class HostingPlacesScreen extends StatelessWidget {
  const HostingPlacesScreen({super.key});

  // Dummy hosting services data
  static const List<Map<String, dynamic>> dummyHostingServices = [
    {
      'name': 'Heroku',
      'description': 'Deploy apps with ease using Heroku’s platform.',
      'icon': Icons.cloud,
      'color': Color(0xFF6762A6), // Heroku purple
    },
    {
      'name': 'Render',
      'description': 'Modern cloud hosting for web apps and APIs.',
      'icon': Icons.api,
      'color': Color(0xFF46A4E8), // Render blue
    },
    {
      'name': 'Railway',
      'description': 'Simple deployment for full-stack applications.',
      'icon': Icons.train,
      'color': Color(0xFF0D0D0D), // Railway dark
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final herokuService = HerokuService();

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: const Text('Hosting Services'),
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Please sign in to view hosting places.',
                style: TextStyle(color: AppColors.primaryText, fontSize: 18),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('services')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.accentYellow));
                }

                final hasServices = snapshot.hasData && snapshot.data!.docs.isNotEmpty;
                final services = hasServices ? snapshot.data!.docs : [];

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: hasServices ? services.length : dummyHostingServices.length,
                  itemBuilder: (context, index) {
                    if (hasServices) {
                      // User-specific services
                      final service = services[index].data() as Map<String, dynamic>;
                      final serviceId = services[index].id;

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('projects')
                            .doc(service['projectId'])
                            .get(),
                        builder: (context, projectSnapshot) {
                          if (projectSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: AppColors.accentYellow));
                          }
                          if (!projectSnapshot.hasData || !projectSnapshot.data!.exists) {
                            return const SizedBox.shrink();
                          }

                          final project = projectSnapshot.data!.data() as Map<String, dynamic>;
                          final githubUrl = project['githubUrl'] as String;
                          final appName = 'bitsphere-$serviceId';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryBackground,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        service['projectName'] ?? 'Unnamed Project',
                                        style: const TextStyle(
                                          color: AppColors.primaryText,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Icon(Icons.cloud, color: AppColors.accentYellow, size: 24),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'GitHub: ${githubUrl.split('/').last}',
                                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: service['herokuAppId'] == null
                                        ? () async {
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
                                                'deployedAt': FieldValue.serverTimestamp(),
                                              });
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Deployed to Heroku!')),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Deployment failed: $e')),
                                              );
                                            }
                                          }
                                        : null,
                                    icon: const Icon(Icons.upload),
                                    label: const Text('Deploy to Heroku'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accentYellow,
                                      foregroundColor: AppColors.primaryBackground,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  FutureBuilder<bool>(
                                    future: service['herokuAppId'] != null
                                        ? herokuService.getAppStatus(service['herokuAppId'])
                                        : Future.value(false),
                                    builder: (context, statusSnapshot) {
                                      if (statusSnapshot.connectionState == ConnectionState.waiting) {
                                        return const CircularProgressIndicator(color: AppColors.accentYellow);
                                      }
                                      final isRunning = statusSnapshot.data ?? false;
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Status: ${isRunning ? 'Running' : 'Stopped'}',
                                            style: TextStyle(
                                              color: isRunning ? Colors.green : AppColors.secondaryText,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Switch(
                                            value: isRunning,
                                            activeColor: AppColors.accentYellow,
                                            onChanged: service['herokuAppId'] != null
                                                ? (value) async {
                                                    try {
                                                      await herokuService.toggleApp(service['herokuAppId'], value);
                                                      (context as Element).markNeedsBuild();
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text('Failed to toggle app: $e')),
                                                      );
                                                    }
                                                  }
                                                : null,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  if (service['herokuAppId'] != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      'App Name: $appName',
                                      style: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Opening $appName.herokuapp.com')),
                                        );
                                      },
                                      child: const Text(
                                        'Visit App',
                                        style: TextStyle(color: AppColors.accentYellow),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      // Dummy hosting service card
                      final dummyService = dummyHostingServices[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dummyService['name'],
                                    style: const TextStyle(
                                      color: AppColors.primaryText,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    dummyService['icon'],
                                    color: dummyService['color'],
                                    size: 24,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                dummyService['description'],
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Connect ${dummyService['name']} coming soon!')),
                                  );
                                },
                                icon: const Icon(Icons.link),
                                label: const Text('Connect Service'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: dummyService['color'],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}