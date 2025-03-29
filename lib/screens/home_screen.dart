import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/auth_service.dart';
import '../utils/colors.dart';
import '../widgets/app_bar.dart';
import '../widgets/side_drawer.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/container_base.dart';
import 'hosting_places_screen.dart';
import 'sign_in_screen.dart';
import 'upload_project_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<String> categories = ['All', 'Web', 'Mobile', 'AI'];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 2:
        return 'Upload';
      case 3:
        return 'Hosting Places';
      case 4:
        return 'Profile';
      default:
        return '';
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return TabBarView(
          controller: _tabController,
          children: categories.map((category) {
            return ContainerBase(category: category);
          }).toList(),
        );
      case 2:
        return FutureBuilder<String?>(
          future: _authService.getUserRole(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data == 'developer') {
              return const UploadProjectScreen();
            }
            return const Center(
              child: Text(
                'Only developers can upload projects.',
                style: TextStyle(color: AppColors.primaryText),
              ),
            );
          },
        );
      case 3:
        return const HostingPlacesScreen();
      case 4:
        return const Center(
          child:
              Text('Profile', style: TextStyle(color: AppColors.primaryText)),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const SignInScreen();
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: CustomAppBar(
            title: _getTitle(_selectedIndex),
            onMenuPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            showTabs: _selectedIndex == 0,
            categories: _selectedIndex == 0 ? categories : [],
            tabController: _selectedIndex == 0 ? _tabController : null,
          ),
          drawer: SideDrawer(onItemSelected: _onItemSelected),
          body: _buildBody(),
          bottomNavigationBar: BottomNavigation(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemSelected,
          ),
          extendBody: true,
        );
      },
    );
  }
}
