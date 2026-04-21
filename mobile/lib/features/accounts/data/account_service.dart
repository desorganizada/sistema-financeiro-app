import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import 'account_model.dart';
import 'account_balance_model.dart';

class AccountService {
  Future<List<AccountModel>> getAccounts() async {
    try {
      final response = await DioClient.dio.get('/accounts');

      return (response.data as List)
          .map((item) => AccountModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Erro ao buscar contas';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao buscar contas');
    }
  }

  Future<List<AccountBalanceModel>> getAccountBalances() async {
    try {
      final response = await DioClient.dio.get('/accounts/balances');

      return (response.data as List)
          .map((item) => AccountBalanceModel.fromJson(item))
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao buscar saldos das contas';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao buscar saldos');
    }
  }

  Future<void> createAccount({
    required String name,
    required String type,
    required String currency,
    required double initialBalance,
    required String? initialBalanceDate,
  }) async {
    try {
      await DioClient.dio.post(
        '/accounts',
        data: {
          'name': name,
          'type': type,
          'currency': currency,
          'initial_balance': initialBalance,
          'initial_balance_date': initialBalanceDate,
        },
      );
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Erro ao criar conta';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao criar conta');
    }
  }

  Future<void> updateAccount({
    required int accountId,
    required String name,
    required String type,
    required String currency,
    required double initialBalance,
    required String? initialBalanceDate,
  }) async {
    try {
      await DioClient.dio.put(
        '/accounts/$accountId',
        data: {
          'name': name,
          'type': type,
          'currency': currency,
          'initial_balance': initialBalance,
          'initial_balance_date': initialBalanceDate,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao atualizar conta';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao atualizar conta');
    }
  }

  Future<void> deleteAccount(int accountId) async {
    try {
      await DioClient.dio.delete('/accounts/$accountId');
    } on DioException catch (e) {
      final message =
          e.response?.data?['detail'] ?? 'Erro ao excluir conta';
      throw Exception(message);
    } catch (_) {
      throw Exception('Erro inesperado ao excluir conta');
    }
  }
}