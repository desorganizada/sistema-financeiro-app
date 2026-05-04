import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/token_storage.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/data/user_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await _authService.getMe();

      if (!mounted) return;
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await TokenStorage.clearToken();

    if (!context.mounted) return;
    context.go('/login');
  }

  Future<void> _openBaseCurrency() async {
    final result = await context.push<UserModel>('/profile/base-currency');

    if (result != null) {
      setState(() {
        _user = result;
      });
    } else {
      await _loadUser();
    }
  }

  Widget _infoCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!)),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const CircleAvatar(
            radius: 40,
            child: Icon(Icons.person, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            _user!.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _user!.email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          _infoCard(
            label: 'Nome',
            value: _user!.name,
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 12),
          _infoCard(
            label: 'E-mail',
            value: _user!.email,
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 12),
          _infoCard(
            label: 'Moeda base',
            value: _user!.baseCurrency,
            icon: Icons.currency_exchange,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openBaseCurrency,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Alterar moeda base'),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sair da conta'),
            ),
          ),
        ],
      ),
    );
  }
}