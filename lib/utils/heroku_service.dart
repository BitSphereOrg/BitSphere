import 'package:dio/dio.dart';

class HerokuService {
  final Dio _dio = Dio();
  static const String herokuApiKey = 'YOUR_HEROKU_API_KEY';
  static const String baseUrl = 'https://api.heroku.com';

  HerokuService() {
    _dio.options.headers['Authorization'] = 'Bearer $herokuApiKey';
    _dio.options.headers['Accept'] = 'application/vnd.heroku+json; version=3';
  }

  Future<String> createApp(String appName) async {
    try {
      final response = await _dio.post(
        '$baseUrl/apps',
        data: {'name': appName},
      );
      return response.data['id'];
    } catch (e) {
      throw Exception('Failed to create Heroku app: $e');
    }
  }

  Future<void> deployApp(String appId, String githubUrl) async {
    try {
      // Set up source for deployment
      final sourceResponse = await _dio.post(
        '$baseUrl/apps/$appId/sources',
      );
      final sourceBlob = sourceResponse.data['source_blob'];

      // Clone and deploy (simplified for demo)
      await _dio.put(
        sourceBlob['put_url'],
        data: {
          'url': githubUrl,
        },
      );
    } catch (e) {
      throw Exception('Failed to deploy to Heroku: $e');
    }
  }

  Future<bool> getAppStatus(String appId) async {
    try {
      final response = await _dio.get('$baseUrl/apps/$appId');
      return response.data['status'] == 'running';
    } catch (e) {
      throw Exception('Failed to get app status: $e');
    }
  }

  Future<void> toggleApp(String appId, bool enable) async {
    try {
      await _dio.patch(
        '$baseUrl/apps/$appId/formation',
        data: {
          'quantity': enable ? 1 : 0,
          'type': 'web',
        },
      );
    } catch (e) {
      throw Exception('Failed to toggle app: $e');
    }
  }
}