import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/auth_service.dart';
import '../utils/colors.dart';

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
  final _collaboratorsController = TextEditingController();
  
  bool _isPaid = false;
  double _price = 0.0;
  String? _selectedCategory;
  final List<String> _categories = [
    'Mobile App', 'Web App', 'AI/ML', 'Game', 'IoT', 'Other'
  ];
  bool _isLoading = false;
  bool _isGitHubVerified = false;
  String? _githubToken;
  List<String> _collaborators = [];

  final AuthService _authService = AuthService();

  Future<void> _verifyGitHubRepo() async {
    if (_githubUrlController.text.isEmpty) {
      _showErrorSnackBar('Please enter a GitHub URL');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.authenticateWithGitHub();
      
      if (result != null && result.accessToken != null) {
        _githubToken = result.accessToken;
        
        // Verify the GitHub URL
        final isValid = await _authService.verifyGitHubUrl(
          _githubUrlController.text, 
          _githubToken!
        );
        
        if (isValid) {
          setState(() {
            _isGitHubVerified = true;
          });
          _showSuccessSnackBar('GitHub repository verified successfully!');
        } else {
          _showErrorSnackBar('Invalid GitHub repository or access denied.');
        }
      } else {
        _showErrorSnackBar('GitHub authentication failed.');
      }
    } catch (e) {
      _showErrorSnackBar('Error verifying GitHub repository: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addCollaborator() {
    final collaborator = _collaboratorsController.text.trim();
    if (collaborator.isNotEmpty) {
      setState(() {
        _collaborators.add(collaborator);
        _collaboratorsController.clear();
      });
    }
  }

  void _removeCollaborator(String collaborator) {
    setState(() {
      _collaborators.remove(collaborator);
    });
  }

  Future<void> _submitProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_isGitHubVerified) {
      _showErrorSnackBar('Please verify your GitHub repository first.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Create project data
        final projectData = {
          'name': _nameController.text,
          'description': _descriptionController.text,
          'githubUrl': _githubUrlController.text,
          'category': _selectedCategory,
          'isPaid': _isPaid,
          'price': _isPaid ? _price : 0.0,
          'developerId': user.uid,
          'developerName': user.displayName,
          'collaborators': _collaborators,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Save to Firestore
        await FirebaseFirestore.instance.collection('projects').add(projectData);
        
        // Format data for API
        final apiData = {
          _selectedCategory!: [
            {
              _nameController.text: {
                'description': _descriptionController.text,
                'githubUrl': _githubUrlController.text,
                'isPaid': _isPaid,
                'price': _isPaid ? _price : 0.0,
                'developerId': user.uid,
                'developerName': user.displayName,
                'collaborators': _collaborators,
              }
            }
          ]
        };
        
        // Send to API
        final response = await http.post(
          Uri.parse('https://api.bitsphere.com/setProject'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(apiData),
        );
        
        if (response.statusCode == 200) {
          _showSuccessSnackBar('Project uploaded successfully!');
          Navigator.pop(context);
        } else {
          _showErrorSnackBar('Error uploading to API: ${response.body}');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error uploading project: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _githubUrlController.dispose();
    _priceController.dispose();
    _collaboratorsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Text(
                        'Upload Your Project',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Share your creation with the BitSphere community',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Project Name
                    _buildFormLabel('Project Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Enter your project name',
                      icon: Icons.title,
                      validator: (value) => value!.isEmpty ? 'Enter a project name' : null,
                    ),
                    const SizedBox(height: 24),

                    // Description
                    _buildFormLabel('Description'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _descriptionController,
                      hintText: 'Describe your project in detail',
                      icon: Icons.description,
                      maxLines: 4,
                      validator: (value) => value!.isEmpty ? 'Enter a description' : null,
                    ),
                    const SizedBox(height: 24),

                    // GitHub URL with verification button
                    _buildFormLabel('GitHub Repository URL'),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _githubUrlController,
                            hintText: 'https://github.com/username/repository',
                            icon: Icons.link,
                            validator: (value) {
                              if (value!.isEmpty) return 'Enter a GitHub URL';
                              if (!Uri.parse(value).isAbsolute || !value.contains('github.com')) {
                                return 'Enter a valid GitHub URL';
                              }
                              return null;
                            },
                            enabled: !_isGitHubVerified,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _isGitHubVerified 
                                    ? Colors.green.withOpacity(0.3) 
                                    : Colors.cyan.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _isGitHubVerified ? null : _verifyGitHubRepo,
                            icon: Icon(
                              _isGitHubVerified ? Icons.check_circle : Icons.verified_user,
                              size: 20,
                            ),
                            label: Text(
                              _isGitHubVerified ? 'Verified' : 'Verify',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isGitHubVerified 
                                  ? Colors.green[700] 
                                  : Colors.cyan[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Category Dropdown
                    _buildFormLabel('Project Category'),
                    const SizedBox(height: 8),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 24),

                    // Collaborators
                    _buildFormLabel('Collaborators (Optional)'),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _collaboratorsController,
                            hintText: 'GitHub username',
                            icon: Icons.person_add,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _addCollaborator,
                            icon: const Icon(
                              Icons.add,
                              size: 20,
                            ),
                            label: Text(
                              'Add',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyan[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_collaborators.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _collaborators.map((collaborator) {
                          return Chip(
                            label: Text(
                              collaborator,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: Colors.grey[800],
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                            onDeleted: () => _removeCollaborator(collaborator),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Paid Project Toggle
                    _buildPaidToggle(),
                    const SizedBox(height: 16),

                    // Price Input (conditional)
                    if (_isPaid) ...[
                      _buildFormLabel('Price (USD)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _priceController,
                        hintText: 'Enter price in USD',
                        icon: Icons.attach_money,
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
                      const SizedBox(height: 24),
                    ],

                    // Upload Button
                    _buildUploadButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        // Loading overlay
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Processing...',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        enabled: enabled,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey[400],
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          errorStyle: GoogleFonts.poppins(
            color: Colors.red[300],
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.grey[400],
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.category,
            color: Colors.grey[400],
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          hintText: 'Select a category',
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          errorStyle: GoogleFonts.poppins(
            color: Colors.red[300],
            fontSize: 12,
          ),
        ),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
        ),
        dropdownColor: Colors.grey[850],
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
    );
  }

  Widget _buildPaidToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.monetization_on,
              color: Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Paid Project',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            Switch(
              value: _isPaid,
              onChanged: (value) {
                setState(() {
                  _isPaid = value;
                  if (!_isPaid) _priceController.clear();
                });
              },
              activeColor: Colors.cyan,
              activeTrackColor: Colors.cyan.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _submitProject,
        icon: const Icon(Icons.cloud_upload),
        label: Text(
          'Upload Project',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}