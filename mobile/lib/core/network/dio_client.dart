import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../storage/token_storage.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();

          print('BASE URL: ${options.baseUrl}');
          print('PATH: ${options.path}');
          print('QUERY: ${options.queryParameters}');
          print('TOKEN: $token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('HEADERS: ${options.headers}');

          handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE STATUS: ${response.statusCode}');
          print('RESPONSE DATA: ${response.data}');
          handler.next(response);
        },
        onError: (e, handler) {
          print('ERROR STATUS: ${e.response?.statusCode}');
          print('ERROR DATA: ${e.response?.data}');
          print('ERROR MESSAGE: ${e.message}');
          handler.next(e);
        },
      ),
    );
}