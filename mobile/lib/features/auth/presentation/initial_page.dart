// lib/features/auth/presentation/initial_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/token_storage.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Aguarda um pouco para garantir que o storage está pronto
    await Future.delayed(const Duration(milliseconds: 100));
    
    final token = await TokenStorage.getToken(); // Usa método antigo
    if (token != null && token.isNotEmpty) {
      if (mounted) {
        context.go('/home');
      }
    } else {
      if (mounted) {
        context.go('/login');
      }
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