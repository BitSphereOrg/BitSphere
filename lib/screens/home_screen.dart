import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/auth_service.dart';
import '../utils/colors.dart';
import '../widgets/my_services_screen.dart';
import 'hosting_places_screen.dart';
import 'profile_screen.dart';
import 'sign_in_screen.dart';
import 'upload_project_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<String> categories = [
    'Mobile App',
    'Web App',
    'AI/ML',
    'Game',
    'IoT',
    'Other'
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  final AuthService _authService = AuthService();
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    setState(() {
      _isLoading = true;
    });
    
    final role = await _authService.getUserRole();
    
    setState(() {
      _userRole = role;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Add this helper to get the correct navigation items and mapping
  List<BottomNavigationBarItem> _getBottomNavItems() {
    if (_userRole == 'developer') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.upload_file), label: 'Upload'),
        BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Hosting'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Hosting'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ];
    }
  }

  // Map selected index to screen index for non-developer
  int _getScreenIndex(int navIndex) {
    if (_userRole == 'developer') {
      return navIndex;
    } else {
      // navIndex: 0->Explore(0), 1->Hosting(2), 2->Profile(3)
      if (navIndex == 0) return 0;
      if (navIndex == 1) return 2;
      if (navIndex == 2) return 3;
      return 0;
    }
  }

  int _getNavIndexFromScreenIndex(int screenIndex) {
    if (_userRole == 'developer') {
      return screenIndex;
    } else {
      // screenIndex: 0->0, 2->1, 3->2
      if (screenIndex == 0) return 0;
      if (screenIndex == 2) return 1;
      if (screenIndex == 3) return 2;
      return 0;
    }
  }

  void _onItemSelected(int navIndex) {
    setState(() {
      _selectedIndex = _getScreenIndex(navIndex);
    });
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Explore';
      case 1:
        return 'Upload';
      case 2:
        return 'Hosting';
      case 3:
        return 'Profile';
      case 4:
        return 'Stats';
      default:
        return '';
    }
  }

  // Fetch projects from API (replace with your backend endpoint)
  Future<List<Map<String, dynamic>>> fetchProjects({String? category}) async {
    // Example using http package
    // Add `http: ^0.13.0` (or latest) to your pubspec.yaml
    // ignore: unnecessary_import

    // Dummy projects for local development/testing
    final List<Map<String, dynamic>> dummyProjects = [
      {
        'name': 'Smart Home Controller',
        'description': 'Control your home appliances remotely using IoT.',
        'type': 'IoT',
        'isPaid': false,
        'budget': '',
        'developer': 'Team Innovate',
      },
      {
        'name': 'AI Chatbot',
        'description': 'A chatbot powered by GPT for customer support.',
        'type': 'AI/ML',
        'isPaid': true,
        'budget': '\$200',
        'developer': 'Alice',
      },
      {
        'name': 'Flutter Weather App',
        'description': 'A beautiful weather app built with Flutter.',
        'type': 'Mobile App',
        'isPaid': false,
        'budget': '',
        'developer': 'Bob',
      },
      {
        'name': 'Online Portfolio',
        'description': 'A web app to showcase your projects and resume.',
        'type': 'Web App',
        'isPaid': false,
        'budget': '',
        'developer': 'Team Webify',
      },
      {
        'name': '2D Platformer Game',
        'description': 'A fun and challenging platformer game.',
        'type': 'Game',
        'isPaid': true,
        'budget': '\$100',
        'developer': 'GameDev Studios',
      },
    ];

    // If you want to use dummies only, return them here:
    // return dummyProjects.where((p) => category == null || p['type'] == category).toList();

    // Otherwise, try fetching from API and fallback to dummies on error
    try {
      final uri = Uri.parse('http://209.74.71.140:50000/fetchProjects${category != null ? '?category=$category' : ''}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        // fallback to dummies
        return dummyProjects.where((p) => category == null || p['type'] == category).toList();
      }
    } catch (e) {
      // fallback to dummies
      return dummyProjects.where((p) => category == null || p['type'] == category).toList();
    }
  }

  // Groups projects by category and returns a map: {category: [projects]}
  Map<String, List<Map<String, dynamic>>> groupProjectsByCategory(List<Map<String, dynamic>> projects) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var project in projects) {
      final category = project['type'] as String;
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(project);
    }
    return grouped;
  }

  // Example usage: get grouped projects as a map
  Future<Map<String, List<Map<String, dynamic>>>> fetchGroupedProjects() async {
    final allProjects = await fetchProjects();
    return groupProjectsByCategory(allProjects);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SignInScreen();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        }
        if (_isLoading || _userRole == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.black,
            extendBody: true,
            appBar: _buildAppBar(),
            drawer: _buildDrawer(),
            body: _buildBody(),
            bottomNavigationBar: _buildBottomNavigation(),
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BitSphere',
              style: GoogleFonts.orbitron(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.cyan.withOpacity(0.8),
                    offset: const Offset(0, 0),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.7),
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Text(
        _getTitle(_selectedIndex),
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.apps_rounded, color: Colors.white),
          onPressed: () {
            const MyServicesScreen();
          },
        ),
      ],
      bottom: _selectedIndex == 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: _buildCategoryTabs(),
            )
          : null,
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(
            color: Colors.grey[800]!,
            width: 0.5,
          ),
          bottom: BorderSide(
            color: Colors.grey[800]!,
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.cyan,
        indicatorWeight: 3,
        labelColor: Colors.cyan,
        unselectedLabelColor: Colors.grey[400],
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        tabs: categories.map((category) => Tab(text: category)).toList(),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.black,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: SafeArea(
            child: Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[800]!,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'BitSphere',
                          style: GoogleFonts.orbitron(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.cyan.withOpacity(0.8),
                                offset: const Offset(0, 0),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Quick Access',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.explore,
                  title: 'Explore',
                  index: 0,
                ),
                if (_userRole == 'developer')
                  _buildDrawerItem(
                    icon: Icons.upload_file,
                    title: 'Upload Project',
                    index: 1,
                  ),
                _buildDrawerItem(
                  icon: Icons.cloud,
                  title: 'Hosting Places',
                  index: 2,
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'Profile',
                  index: 3,
                ),
                if (_userRole == 'developer')
                  _buildDrawerItem(
                    icon: Icons.bar_chart,
                    title: 'Stats',
                    index: 4,
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _authService.signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.cyan : Colors.grey[400],
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: isSelected ? Colors.cyan : Colors.white,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      onTap: () {
        _onItemSelected(index);
        Navigator.pop(context);
      },
      tileColor: isSelected ? Colors.cyan.withOpacity(0.1) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return TabBarView(
          controller: _tabController,
          children: categories.map((category) {
            return _buildProjectGrid(category);
          }).toList(),
        );
      case 1:
        // Only show UploadProjectScreen for developers, fetch role live
        return FutureBuilder<String?>(
          future: _authService.getUserRole(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == 'developer') {
              return const UploadProjectScreen();
            }
            return _buildRestrictedAccessView('Only developers can upload projects.');
          },
        );
      case 2:
        return const HostingPlacesScreen();
      case 3:
        return const ProfileScreen();
      case 4:
        // Only show StatsScreen for developers, fetch role live
        return FutureBuilder<String?>(
          future: _authService.getUserRole(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == 'developer') {
              return const StatsScreen();
            }
            return _buildRestrictedAccessView('Stats are only available for developers.');
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRestrictedAccessView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline,
            color: Colors.grey,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectGrid(String category) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchProjects(category: category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load projects.',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }
        final projects = snapshot.data ?? [];
        if (projects.isEmpty) {
          return Center(
            child: Text(
              'No projects found.',
              style: GoogleFonts.poppins(color: Colors.grey[400]),
            ),
          );
        }
        return Container(
          color: Colors.black,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return _buildProjectCard(project);
            },
          ),
        );
      },
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey[800],
              child: Stack(
                children: [
                  // Placeholder for project image
                  Center(
                    child: Icon(
                      _getIconForCategory(project['type']),
                      size: 64,
                      color: Colors.grey[700],
                    ),
                  ),
                  // Free/Paid badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: project['isPaid'] ? Colors.amber[700] : Colors.green[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        project['isPaid'] ? 'PAID' : 'FREE',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Project details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        project['type'],
                        style: GoogleFonts.poppins(
                          color: Colors.cyan,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (project['isPaid'])
                      Text(
                        project['budget']!,
                        style: GoogleFonts.poppins(
                          color: Colors.amber,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  project['name'],
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  project['description'],
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      project['developer'].contains('Team') 
                          ? Icons.people 
                          : Icons.person,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      project['developer'],
                      style: GoogleFonts.poppins(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Demo action
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Demo',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Use Now action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Use Now',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Mobile App':
        return Icons.smartphone;
      case 'Web App':
        return Icons.web;
      case 'AI/ML':
        return Icons.psychology;
      case 'Game':
        return Icons.sports_esports;
      case 'IoT':
        return Icons.devices;
      default:
        return Icons.code;
    }
  }

  Widget _buildBottomNavigation() {
    final items = _getBottomNavItems();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            currentIndex: _getNavIndexFromScreenIndex(_selectedIndex),
            onTap: _onItemSelected,
            backgroundColor: Colors.black.withOpacity(0.7),
            selectedItemColor: Colors.cyan,
            unselectedItemColor: Colors.grey[600],
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            items: items,
          ),
        ),
      ),
    );
  }
}
