// lib/features/auth/data/auth_service.dart

import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/token_storage.dart';
import 'user_model.dart';

class AuthService {
  
  Future<String> login({required String email, required String password}) async {
    try {
      final response = await DioClient.dio.post(
        '/auth/login',
        data: {
          'username': email,
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];
      
      await TokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      
      return accessToken;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Erro ao fazer login';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao fazer login');
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await DioClient.dio.get('/auth/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Erro ao buscar usuário';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao buscar usuário');
    }
  }

  Future<String> refreshToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await DioClient.dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newAccessToken = response.data['access_token'];
      await TokenStorage.saveAccessToken(newAccessToken);
      
      return newAccessToken;
    } on DioException catch (e) {
      await TokenStorage.clearTokens();
      throw Exception('Sessão expirada. Faça login novamente.');
    } catch (_) {
      throw Exception('Erro ao renovar sessão');
    }
  }

  Future<UserModel> updateBaseCurrency(String newCurrency) async {
    try {
      final response = await DioClient.dio.put(
        '/users/me/currency',
        data: {'base_currency': newCurrency},
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Erro ao atualizar moeda';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao atualizar moeda');
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearTokens();
  }
}