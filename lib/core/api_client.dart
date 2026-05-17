import 'dart:convert';

import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => message;
}

class ApiClient {
  final TokenStorage tokenStorage;

  ApiClient({
    required this.tokenStorage,
  });

  Uri _uri(String path) {
    return Uri.parse('${AppConfig.baseUrl}$path');
  }

  Future<Map<String, String>> _headers({
    bool withAuth = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (withAuth) {
      final token = await tokenStorage.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(String path, {bool withAuth = true}) async {
    final response = await http.get(
      _uri(path),
      headers: await _headers(withAuth: withAuth),
    );

    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final response = await http.post(
      _uri(path),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final response = await http.patch(
      _uri(path),
      headers: await _headers(withAuth: withAuth),
      body: jsonEncode(body ?? {}),
    );

    return _handleResponse(response);
  }

  Future<dynamic> delete(String path, {bool withAuth = true}) async {
    final response = await http.delete(
      _uri(path),
      headers: await _headers(withAuth: withAuth),
    );

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    dynamic decoded;

    try {
      decoded = body.isEmpty ? null : jsonDecode(body);
    } catch (_) {
      throw ApiException(
        statusCode: statusCode,
        message: 'Server mengembalikan response yang bukan JSON.',
      );
    }

    if (statusCode >= 200 && statusCode < 300) {
      return decoded;
    }

    String message = 'Terjadi kesalahan pada server.';

    if (decoded is Map<String, dynamic>) {
      if (decoded['message'] != null) {
        message = decoded['message'].toString();
      } else if (decoded['errors'] != null) {
        message = decoded['errors'].toString();
      }
    }

    throw ApiException(
      statusCode: statusCode,
      message: message,
    );
  }
}