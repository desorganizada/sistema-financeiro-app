import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'import_result_model.dart';

class ImportService {
  Future<ImportResultModel> importCsv(File file) async {
    try {
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await DioClient.dio.post(
        '/imports/csv',
        data: formData,
      );

      return ImportResultModel.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao importar CSV';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao importar CSV');
    }
  }

  Future<ImportResultModel> importOfx({
    required File file,
    required int accountId,
    required int categoryId,
  }) async {
    try {
      final fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'account_id': accountId,
        'category_id': categoryId,
      });

      final response = await DioClient.dio.post(
        '/imports/ofx',
        data: formData,
      );

      return ImportResultModel.fromJson(response.data);
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao importar OFX';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao importar OFX');
    }
  }
}