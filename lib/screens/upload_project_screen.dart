import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/auth_service.dart';

class UploadProjectScreen extends StatefulWidget {
  const UploadProjectScreen({super.key});

  @override
  State<UploadProjectScreen> createState() => _UploadProjectScreenState();
}

class _UploadProjectScreenState extends State<UploadProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _githubUrlController = TextEditingController();
  bool _isPaid = false;
  double _price = 0.0;

  Future<void> _submitProject() async {
    if (_formKey.currentState!.validate()) {
      final isValidGitHubUrl =
          await AuthService().verifyGitHubUrl(_githubUrlController.text);
      if (!isValidGitHubUrl) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid GitHub URL or access denied.')),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('projects').add({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'githubUrl': _githubUrlController.text,
          'isPaid': _isPaid,
          'price': _isPaid ? _price : 0.0,
          'developerId': user.uid,
          'developerName': user.displayName,
          'createdAt': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project uploaded successfully!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _githubUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Project Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _githubUrlController,
                decoration: const InputDecoration(labelText: 'GitHub URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a GitHub URL';
                  }
                  if (!Uri.parse(value).isAbsolute ||
                      !value.contains('github.com')) {
                    return 'Please enter a valid GitHub URL';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Paid Project'),
                value: _isPaid,
                onChanged: (value) {
                  setState(() {
                    _isPaid = value;
                  });
                },
              ),
              if (_isPaid)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Price (USD)'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _price = double.tryParse(value) ?? 0.0;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null ||
                        double.parse(value) <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitProject,
                child: const Text('Upload Project'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
