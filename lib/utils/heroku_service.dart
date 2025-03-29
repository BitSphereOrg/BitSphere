import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HerokuService {
  final Dio _dio = Dio();

  Future<String> createApp(String appName) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    final response = await _dio.post(
      'http://203.161.39.224:50000/heroku/create-app',
      data: {'appName': appName},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create Heroku app');
    }

    return response.data['data']['appId'];
  }

  Future<void> deployApp(String appId, String githubUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    final response = await _dio.post(
      'http://203.161.39.224:50000/heroku/deploy-app',
      data: {'appId': appId, 'githubUrl': githubUrl},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to deploy to Heroku');
    }
  }

  Future<bool> getAppStatus(String appId) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    final response = await _dio.get(
      'http://203.161.39.224:50000/heroku/app-status/$appId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get app status');
    }

    return response.data['data']['isRunning'];
  }

  Future<void> toggleApp(String appId, bool enable) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    final response = await _dio.post(
      'http://203.161.39.224:50000/heroku/toggle-app',
      data: {'appId': appId, 'enable': enable},
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle app');
    }
  }
}