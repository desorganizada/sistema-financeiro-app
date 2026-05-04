import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../data/account_service.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _nameController = TextEditingController();
  final _initialBalanceController = TextEditingController(text: '0');
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

      await _accountService.createAccount(
        name: _nameController.text.trim(),
        type: _selectedType,
        currency: _selectedCurrency,
        initialBalance: initialBalance,
        initialBalanceDate: dateString,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Conta criada com sucesso!'),
          backgroundColor: AppColors.primaryTerracota ,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      backgroundColor: AppColors.backgroundSand,
      appBar: AppBar(
        title: const Text(
          'Nova Conta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryTerracota,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com ícone
            _buildHeader(),
            const SizedBox(height: 20),
            
            // Título
            _buildTitle(),
            const SizedBox(height: 32),
            
            // Card do formulário
            _buildFormCard(),
            const SizedBox(height: 20),
            
            // Container informativo
            _buildInfoContainer(),
            const SizedBox(height: 24),
            
            // Botão criar
            _buildSubmitButton(),
            const SizedBox(height: 16),
            
            // Mensagem de erro
            if (_message != null) _buildErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryTerracota, AppColors.lightTerracota],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryTerracota.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.account_balance_wallet_outlined,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Center(
          child: Text(
            'Criar nova conta',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Preencha os dados abaixo para começar',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceSand,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações básicas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          
          // Nome da conta
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome da conta',
              hintText: 'Ex: Banco do Brasil, Nubank',
              prefixIcon: Icon(Icons.account_balance_wallet),
            ),
          ),
          const SizedBox(height: 16),
          
          // Tipo e Moeda
          Row(
            children: [
              Expanded(child: _buildTypeDropdown()),
              const SizedBox(width: 16),
              Expanded(child: _buildCurrencyDropdown()),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Divider(color: AppColors.borderSand),
          
          const SizedBox(height: 24),
          
          Text(
            'Saldo inicial',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          
          // Data e Valor
          Row(
            children: [
              Expanded(child: _buildDateField()),
              const SizedBox(width: 16),
              Expanded(child: _buildAmountField()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      decoration: const InputDecoration(
        labelText: 'Tipo',
        prefixIcon: Icon(Icons.category),
      ),
      items: const [
        DropdownMenuItem(value: 'corrente', child: Text('💰 Conta Corrente')),
        DropdownMenuItem(value: 'carteira', child: Text('👛 Carteira')),
        DropdownMenuItem(value: 'cartao', child: Text('💳 Cartão')),
        DropdownMenuItem(value: 'investimento', child: Text('📈 Investimento')),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _selectedType = value);
      },
    );
  }

  Widget _buildCurrencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCurrency,
      decoration: const InputDecoration(
        labelText: 'Moeda',
        prefixIcon: Icon(Icons.currency_exchange),
      ),
      items: const [
        DropdownMenuItem(value: 'BRL', child: Text('🇧🇷 Real (BRL)')),
        DropdownMenuItem(value: 'USD', child: Text('🇺🇸 Dólar (USD)')),
        DropdownMenuItem(value: 'EUR', child: Text('🇪🇺 Euro (EUR)')),
        DropdownMenuItem(value: 'GBP', child: Text('🇬🇧 Libra (GBP)')),
        DropdownMenuItem(value: 'NZD', child: Text('🇳🇿 Dólar Neozelandês (NZD)')),  // ✅ ADICIONADO
      ],
      onChanged: (value) {
        if (value != null) setState(() => _selectedCurrency = value);
      },
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: _dateController,
      decoration: const InputDecoration(
        labelText: 'Data',
        prefixIcon: Icon(Icons.calendar_today),
      ),
      readOnly: true,
      onTap: () => _selectDate(context),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: _initialBalanceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,]\d{0,2})?$')),
      ],
      decoration: InputDecoration(
        labelText: 'Valor',
        prefixIcon: const Icon(Icons.monetization_on),
        suffixText: _selectedCurrency,
        suffixStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryTerracota,
        ),
      ),
    );
  }

  Widget _buildInfoContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.highlight,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.lightTerracota.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightTerracota.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.info_outline, color: AppColors.primaryTerracota, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Conversão automática',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'O valor será mantido na moeda original. A conversão para sua moeda base será exibida no dashboard.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMedium,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _save,
        style: AppStyles.primaryButtonStyle,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Criar Conta'),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _message!,
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}