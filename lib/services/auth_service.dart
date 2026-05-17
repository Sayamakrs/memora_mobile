import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../models/app_user.dart';

class AuthService {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthService({
    required this.apiClient,
    required this.tokenStorage,
  });

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await apiClient.post(
      '/register',
      withAuth: false,
      body: {
        'name': name,
        'email': email,
        'password': password,
        'aliases': [name, 'Aku', 'Saya'],
      },
    );

    final token = data['token']?.toString();

    if (token == null || token.isEmpty) {
      throw ApiException(
        statusCode: 500,
        message: 'Token tidak ditemukan pada response register.',
      );
    }

    await tokenStorage.saveToken(token);

    return AppUser.fromJson(data['user']);
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final data = await apiClient.post(
      '/login',
      withAuth: false,
      body: {
        'email': email,
        'password': password,
      },
    );

    final token = data['token']?.toString();

    if (token == null || token.isEmpty) {
      throw ApiException(
        statusCode: 500,
        message: 'Token tidak ditemukan pada response login.',
      );
    }

    await tokenStorage.saveToken(token);

    return AppUser.fromJson(data['user']);
  }

  Future<AppUser> me() async {
    final data = await apiClient.get('/me');
    return AppUser.fromJson(data['user']);
  }

  Future<void> logout() async {
    try {
      await apiClient.post('/logout');
    } finally {
      await tokenStorage.clearToken();
    }
  }
}