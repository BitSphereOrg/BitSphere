import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/auth_service.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;
  final AuthService authService = AuthService();

  // Sign-in method with role
  Future<void> _signIn(String role) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await authService.signInWithGoogle(role);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      body: Stack(
        children: [
          // Background with fading image
          Positioned.fill(
            child: Column(
              children: [
                // Top half: Background image with fade
                Expanded(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.transparent,
                        ],
                        stops: [0.5, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      'assets/images/bitsphere_logo.jpeg',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                // Bottom half: Solid black
                Expanded(
                  child: Container(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // BitSphere title
                Text(
                  'BitSphere',
                  style: GoogleFonts.orbitron(
                    fontSize: 48,
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
                const SizedBox(height: 40),
                // Sign In as User button
                _buildSignInButton(
                  icon: FontAwesomeIcons.google,
                  text: 'Sign In As User',
                  onPressed: () => _signIn('user'),
                ),
                const SizedBox(height: 20),
                // Sign In as Developer button
                _buildSignInButton(
                  icon: FontAwesomeIcons.google,
                  text: 'Sign In As Developer',
                  onPressed: () => _signIn('developer'),
                ),
              ],
            ),
          ),
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Custom button widget with neon shadow
  Widget _buildSignInButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: FaIcon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        label: Text(
          text,
          style: GoogleFonts.orbitron(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: const BorderSide(color: Colors.cyan, width: 2),
          ),
        ),
      ),
    );
  }
}