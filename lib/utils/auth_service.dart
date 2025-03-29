import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle(String role) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return user;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['role'] as String?;
    }
    return null;
  }

  final FlutterAppAuth _appAuth = FlutterAppAuth();
  static const String clientId = 'Ov23lioJGcNoTE42J0lm';
  static const String clientSecret = '68e459d4ffaf7c1efc2581cf2b6df534d2a239cc';
  static const String redirectUrl = 'bitsphere://callback';
  static const String githubAuthUrl = 'https://github.com/login/oauth/authorize';
  static const String githubTokenUrl = 'https://github.com/login/oauth/access_token';
  static const String githubApiUrl = 'https://api.github.com';

  Future<bool> verifyGitHubUrl(String githubUrl) async {
    try {
      final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          clientSecret: clientSecret,
          serviceConfiguration: const AuthorizationServiceConfiguration(
            authorizationEndpoint: githubAuthUrl,
            tokenEndpoint: githubTokenUrl,
          ),
          scopes: ['repo', 'user'],
        ),
      );

      if (result == null || result.accessToken == null) {
        return false;
      }

      // Verify the GitHub URL
      final repoPath = githubUrl.replaceFirst('https://github.com/', '');
      final response = await http.get(
        Uri.parse('$githubApiUrl/repos/$repoPath'),
        headers: {'Authorization': 'Bearer ${result.accessToken}'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying GitHub URL: $e');
      return false;
    }
  }
}