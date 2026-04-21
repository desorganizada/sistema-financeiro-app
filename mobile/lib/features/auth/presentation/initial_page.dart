import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/token_storage.dart';
import '../data/auth_service.dart';
import '../data/user_model.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final token = await TokenStorage.getToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      context.go('/login');
      return;
    }

    try {
      final authService = AuthService();
      final UserModel user = await authService.getMe();

      if (!mounted) return;
      context.go('/home', extra: user);
    } catch (_) {
      await TokenStorage.clearToken();

      if (!mounted) return;
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}