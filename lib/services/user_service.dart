// lib/services/user_service.dart

import '../models/app_user.dart';
import '../core/api_client.dart';

class UserService {
  final ApiClient apiClient;

  UserService({
    required this.apiClient,
  });

  Future<AppUser?> updateProfile({
    required String name,
    required List<String> aliases,
  }) async {
    final response = await apiClient.patch(
      '/profile',
      body: {
        'name': name,
        'aliases': aliases,
      },
    );

    final userData = response['data'] ?? response['user'];

    if (userData is Map<String, dynamic>) {
      return AppUser.fromJson(userData);
    }

    if (userData is Map && userData.isNotEmpty) {
      return AppUser.fromJson(Map<String, dynamic>.from(userData));
    }

    return null;
  }
}
