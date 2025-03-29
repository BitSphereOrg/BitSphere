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
  final _priceController = TextEditingController();
  
  bool _isPaid = false;
  double _price = 0.0;
  String? _selectedCategory;
  final List<String> _categories = [
    'Mobile App', 'Web App', 'AI/ML', 'Game', 'IoT', 'Other'
  ];

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
          'category': _selectedCategory,
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
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Project', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Project Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter a project name' : null,
                ),
                const SizedBox(height: 15),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? 'Enter a description' : null,
                ),
                const SizedBox(height: 15),

                // GitHub URL
                TextFormField(
                  controller: _githubUrlController,
                  decoration: InputDecoration(
                    labelText: 'GitHub URL',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) return 'Enter a GitHub URL';
                    if (!Uri.parse(value).isAbsolute || !value.contains('github.com')) {
                      return 'Enter a valid GitHub URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Select Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) => value == null ? 'Select a category' : null,
                ),
                const SizedBox(height: 15),

                // Paid Project Toggle
                SwitchListTile(
                  title: const Text('Paid Project'),
                  value: _isPaid,
                  onChanged: (value) {
                    setState(() {
                      _isPaid = value;
                      if (!_isPaid) _priceController.clear();
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Price Input
                if (_isPaid)
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price (USD)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _price = double.tryParse(value) ?? 0.0;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter a price';
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return 'Enter a valid price';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 20),

                // Upload Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitProject,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Upload Project', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
