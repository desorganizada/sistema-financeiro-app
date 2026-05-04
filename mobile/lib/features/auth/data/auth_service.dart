import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import 'user_model.dart';

class AuthService {
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await DioClient.dio.post(
        '/auth/login',
        data: FormData.fromMap({
          'username': email,
          'password': password,
        }),
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      return response.data['access_token'];
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Erro ao fazer login';

      if (data is Map && data['detail'] != null) {
        message = data['detail'].toString();
      } else if (data != null) {
        message = data.toString();
      }

      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado no login');
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

  Future<UserModel> updateBaseCurrency({
    required String baseCurrency,
  }) async {
    try {
      final response = await DioClient.dio.put(
        '/users/base-currency',
        data: {
          'base_currency': baseCurrency,
        },
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao atualizar moeda base';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao atualizar moeda base');
    }
  }
}