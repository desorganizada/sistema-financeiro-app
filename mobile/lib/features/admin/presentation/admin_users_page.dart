import 'package:flutter/material.dart';

import '../../../shared/widgets/app_error_state.dart';
import '../../../shared/widgets/app_loading.dart';
import '../data/admin_user_model.dart';
import '../data/admin_user_service.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final AdminUserService _service = AdminUserService();

  late Future<List<AdminUserModel>> _future;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    _future = _service.getUsers();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadUsers();
    });

    await _future;
  }

  // =============================
  // CREATE USER
  // =============================
  Future<void> _createUser() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final currencyController = TextEditingController(text: 'BRL');
    bool isAdmin = false;

    final created = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            title: const Text('Novo usuário'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Senha'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: currencyController,
                    decoration: const InputDecoration(labelText: 'Moeda base'),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    title: const Text('Administrador'),
                    value: isAdmin,
                    onChanged: (v) {
                      setLocalState(() => isAdmin = v);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await _service.createUser(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      baseCurrency:
                          currencyController.text.trim().toUpperCase(),
                      isAdmin: isAdmin,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: const Text('Criar'),
              ),
            ],
          );
        },
      ),
    );

    if (created == true) {
      await _refresh();
    }
  }

  // =============================
  // EDIT USER
  // =============================
  Future<void> _editUser(AdminUserModel user) async {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final currencyController =
        TextEditingController(text: user.baseCurrency);
    bool isAdmin = user.isAdmin;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocalState) {
          return AlertDialog(
            title: const Text('Editar usuário'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController),
                const SizedBox(height: 10),
                TextField(controller: emailController),
                const SizedBox(height: 10),
                TextField(controller: currencyController),
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Administrador'),
                  value: isAdmin,
                  onChanged: (v) {
                    setLocalState(() => isAdmin = v);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  try {
                    await _service.updateUser(
                      userId: user.id,
                      name: nameController.text,
                      email: emailController.text,
                      baseCurrency:
                          currencyController.text.toUpperCase(),
                      isAdmin: isAdmin,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );

    if (saved == true) {
      await _refresh();
    }
  }

  // =============================
  // CHANGE PASSWORD
  // =============================
  Future<void> _changePassword(AdminUserModel user) async {
    final controller = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Alterar senha'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Nova senha'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _service.updatePassword(
                  userId: user.id,
                  newPassword: controller.text.trim(),
                );

                if (!context.mounted) return;
                Navigator.pop(context, true);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha atualizada')),
      );
    }
  }

  // =============================
  // DELETE
  // =============================
  Future<void> _deleteUser(AdminUserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir usuário'),
        content: Text('Deseja excluir ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _service.deleteUser(user.id);
    await _refresh();
  }

  // =============================
  // UI
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createUser,
          ),
        ],
      ),
      body: FutureBuilder<List<AdminUserModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading(message: 'Carregando...');
          }

          if (snapshot.hasError) {
            return AppErrorState(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final users = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return Card(
                child: ListTile(
                  title: Text(user.name),
                  subtitle: Text(
                    '${user.email}\n${user.baseCurrency} • ${user.isAdmin ? "Admin" : "User"}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') _editUser(user);
                      if (value == 'password') _changePassword(user);
                      if (value == 'delete') _deleteUser(user);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Editar'),
                      ),
                      PopupMenuItem(
                        value: 'password',
                        child: Text('Alterar senha'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Excluir'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}