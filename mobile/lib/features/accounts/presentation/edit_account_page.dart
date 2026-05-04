import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/account_model.dart';
import '../data/account_service.dart';

class EditAccountPage extends StatefulWidget {
  final AccountModel account;

  const EditAccountPage({super.key, required this.account});

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  final _dateController = TextEditingController();

  final AccountService _accountService = AccountService();

  String _selectedType = 'corrente';
  String _selectedCurrency = 'BRL';
  DateTime? _selectedDate;
  bool _isLoading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    
    // Preenche os campos com os dados da conta
    _nameController.text = widget.account.name;
    _selectedType = widget.account.type;
    _selectedCurrency = widget.account.currency;
    
    // Para saldo inicial, usamos o balance atual como referência
    // (o backend não retorna o saldo inicial original separadamente)
    final balance = widget.account.balance ?? 0.0;
    _initialBalanceController.text = balance.toStringAsFixed(2);
    
    _selectedDate = DateTime.now();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _message = 'Por favor, informe o nome da conta';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final balanceText = _initialBalanceController.text.replaceAll(',', '.');
      final initialBalance = double.tryParse(balanceText) ?? 0;

      if (initialBalance < 0) {
        setState(() {
          _message = 'O saldo inicial não pode ser negativo';
        });
        return;
      }

      final dateString = _selectedDate != null 
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null;

      await _accountService.updateAccount(
        accountId: widget.account.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        currency: _selectedCurrency,
        initialBalance: initialBalance,
        initialBalanceDate: dateString,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Conta atualizada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
      
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta'),
        content: const Text('Tem certeza que deseja excluir esta conta? Todas as transações associadas também serão excluídas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
        _message = null;
      });

      try {
        await _accountService.deleteAccount(widget.account.id);
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } catch (e) {
        setState(() {
          _message = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Conta'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _isLoading ? null : _deleteAccount,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Nome da conta
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome da conta *',
                hintText: 'Ex: Banco do Brasil, Nubank, Carteira',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tipo da conta
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(value: 'corrente', child: Text('💰 Conta Corrente')),
                DropdownMenuItem(value: 'carteira', child: Text('👛 Carteira')),
                DropdownMenuItem(value: 'cartao', child: Text('💳 Cartão de Crédito')),
                DropdownMenuItem(value: 'investimento', child: Text('📈 Investimento')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Moeda
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'Moeda',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_exchange),
              ),
              items: const [
                DropdownMenuItem(value: 'BRL', child: Text('🇧🇷 Real (BRL)')),
                DropdownMenuItem(value: 'USD', child: Text('🇺🇸 Dólar Americano (USD)')),
                DropdownMenuItem(value: 'EUR', child: Text('🇪🇺 Euro (EUR)')),
                DropdownMenuItem(value: 'GBP', child: Text('🇬🇧 Libra Esterlina (GBP)')),
                DropdownMenuItem(value: 'NZD', child: Text('🇳🇿 Dólar Neozelandês (NZD)')),
                DropdownMenuItem(value: 'AED', child: Text('🇦🇪 Dirham dos EAU (AED)')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCurrency = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Data do saldo inicial
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Data do saldo inicial',
                hintText: 'Data que o saldo foi registrado',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            
            // Saldo inicial
            TextField(
              controller: _initialBalanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'^\d+([.,]\d{0,2})?$'),
                ),
              ],
              decoration: InputDecoration(
                labelText: 'Saldo atual',
                hintText: 'Ex: 1000.00',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.monetization_on),
                suffixText: _selectedCurrency,
                helperText: 'Este será o novo saldo da conta',
                helperStyle: const TextStyle(fontSize: 12),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Informação da conta atual
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey.shade600, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Informações atuais',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saldo atual em ${widget.account.currency}: ${widget.account.balance?.toStringAsFixed(2) ?? "0.00"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botão de salvar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Salvar Alterações',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Mensagem de erro
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _message!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}