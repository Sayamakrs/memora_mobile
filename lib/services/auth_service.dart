import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../models/app_user.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '839466021455-kg72smu2uc0qfdsvfdsjughssu55lm6n.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  Future<AppUser?> loginWithGoogle() async {
    try {
      // Pemicu pop-up pilihan akun Google di perangkat
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Jika user menekan tombol back / membatalkan login
      if (googleUser == null) return null;

      // Ambil credential autentikasi dari Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw ApiException(
          statusCode: 400,
          message: 'Gagal mendapatkan ID Token dari Google.',
        );
      }

      // Kirim token ke endpoint Laravel kamu via ApiClient
      final data = await apiClient.post(
        '/google/auth', // endpoint di laravel
        withAuth: false, // Belum butuh token sanctum karena proses login
        body: {
          'id_token': idToken,
        },
      );

      final token = data['token']?.toString();

      if (token == null || token.isEmpty) {
        throw ApiException(
          statusCode: 500,
          message: 'Token tidak ditemukan pada response login Google.',
        );
      }

      // Simpan token Sanctum ke TokenStorage
      await tokenStorage.saveToken(token);

      // Return data user yang di-mapping ke model AppUser
      return AppUser.fromJson(data['user']);
    } catch (e) {
      // Re-throw jika itu sudah berupa ApiException agar bisa di-handle di UI
      if (e is ApiException) rethrow;

      throw ApiException(
        statusCode: 500,
        message: 'Terjadi kesalahan saat login Google: $e',
      );
    }
  }

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
