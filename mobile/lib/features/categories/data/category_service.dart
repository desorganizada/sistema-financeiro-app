import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'category_model.dart';

class CategoryService {
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await DioClient.dio.get('/categories');
      final data = response.data;

      List listData;

      if (data is List) {
        listData = data;
      } else if (data is Map<String, dynamic>) {
        if (data['items'] is List) {
          listData = data['items'] as List;
        } else if (data['data'] is List) {
          listData = data['data'] as List;
        } else {
          throw Exception('Resposta da API inválida para categorias');
        }
      } else {
        throw Exception('Formato inesperado ao buscar categorias');
      }

      return listData
          .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final responseData = e.response?.data;

      String message = 'Erro ao buscar categorias';

      if (responseData is Map<String, dynamic>) {
        message = responseData['detail']?.toString() ?? message;
      } else if (responseData != null) {
        message = responseData.toString();
      } else if (e.message != null) {
        message = e.message!;
      }

      throw Exception(message);
    } catch (e) {
      print('ERRO REAL getCategories: $e');
      throw Exception('Erro inesperado ao buscar categorias: $e');
    }
  }

  Future<void> createCategory({
    required String name,
    required String type,
    required String? groupName,
  }) async {
    try {
      await DioClient.dio.post(
        '/categories',
        data: {
          'name': name,
          'type': type,
          'group_name': groupName,
        },
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;

      String message = 'Erro ao criar categoria';

      if (responseData is Map<String, dynamic>) {
        message = responseData['detail']?.toString() ?? message;
      } else if (responseData != null) {
        message = responseData.toString();
      } else if (e.message != null) {
        message = e.message!;
      }

      throw Exception(message);
    } catch (e) {
      throw Exception('Erro inesperado ao criar categoria: $e');
    }
  }

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required String type,
    required String? groupName,
  }) async {
    try {
      await DioClient.dio.put(
        '/categories/$categoryId',
        data: {
          'name': name,
          'type': type,
          'group_name': groupName,
        },
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;

      String message = 'Erro ao atualizar categoria';

      if (responseData is Map<String, dynamic>) {
        message = responseData['detail']?.toString() ?? message;
      } else if (responseData != null) {
        message = responseData.toString();
      } else if (e.message != null) {
        message = e.message!;
      }

      throw Exception(message);
    } catch (e) {
      throw Exception('Erro inesperado ao atualizar categoria: $e');
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      await DioClient.dio.delete('/categories/$categoryId');
    } on DioException catch (e) {
      final responseData = e.response?.data;

      String message = 'Erro ao excluir categoria';

      if (responseData is Map<String, dynamic>) {
        message = responseData['detail']?.toString() ?? message;
      } else if (responseData != null) {
        message = responseData.toString();
      } else if (e.message != null) {
        message = e.message!;
      }

      throw Exception(message);
    } catch (e) {
      throw Exception('Erro inesperado ao excluir categoria: $e');
    }
  }
}