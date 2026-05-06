// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'dart:async'; 
import '../storage/token_storage.dart';

class DioClient {
  static late Dio dio;
  static bool _isRefreshing = false;
  static final List<QueuedRequest> _queue = [];

  static void init() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://localhost:8000',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Só tenta refresh se for 401 e NÃO for a requisição de refresh
        final isRefreshRequest = e.requestOptions.path == '/auth/refresh';
        
        if (e.response?.statusCode == 401 && !isRefreshRequest && !_isRefreshing) {
          _isRefreshing = true;
          
          try {
            final refreshToken = await TokenStorage.getRefreshToken();
            if (refreshToken == null) {
              throw Exception('No refresh token');
            }
            
            final response = await dio.post(
              '/auth/refresh',
              data: {'refresh_token': refreshToken},
            );
            
            final newAccessToken = response.data['access_token'];
            await TokenStorage.saveAccessToken(newAccessToken);
            
            // Refaz a requisição original
            final options = e.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(options);
            
            return handler.resolve(retryResponse);
          } catch (refreshError) {
            await TokenStorage.clearTokens();
            return handler.next(e);
          } finally {
            _isRefreshing = false;
          }
        }
        
        return handler.next(e);
      },
    ));
  }
}

class QueuedRequest {
  final Completer<Response> completer;
  final RequestOptions requestOptions;

  QueuedRequest({
    required this.completer,
    required this.requestOptions,
  });
}