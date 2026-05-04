import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'admin_user_model.dart';

class AdminUserService {
  Future<List<AdminUserModel>> getUsers() async {
    try {
      final response = await DioClient.dio.get('/users/admin');

      return (response.data as List)
          .map((item) => AdminUserModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao buscar usuários';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao buscar usuários');
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String baseCurrency,
    required bool isAdmin,
  }) async {
    try {
      await DioClient.dio.post(
        '/users/admin',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'base_currency': baseCurrency,
          'is_admin': isAdmin,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao criar usuário';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao criar usuário');
    }
  }

  Future<void> updateUser({
    required int userId,
    required String name,
    required String email,
    required String baseCurrency,
    required bool isAdmin,
  }) async {
    try {
      await DioClient.dio.put(
        '/users/admin/$userId',
        data: {
          'name': name,
          'email': email,
          'base_currency': baseCurrency,
          'is_admin': isAdmin,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao atualizar usuário';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao atualizar usuário');
    }
  }

  Future<void> updatePassword({
    required int userId,
    required String newPassword,
  }) async {
    try {
      await DioClient.dio.put(
        '/users/admin/$userId/password',
        data: {
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao alterar senha';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao alterar senha');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await DioClient.dio.delete('/users/admin/$userId');
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao excluir usuário';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao excluir usuário');
    }
  }
}