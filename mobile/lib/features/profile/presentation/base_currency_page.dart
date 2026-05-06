import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/data/user_model.dart';

class BaseCurrencyPage extends StatefulWidget {
  final UserModel? user;

  const BaseCurrencyPage({super.key, this.user});

  @override
  State<BaseCurrencyPage> createState() => _BaseCurrencyPageState();
}

class _BaseCurrencyPageState extends State<BaseCurrencyPage> {
  final AuthService _authService = AuthService();

  String? _selectedCurrency;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _message;

  List<Map<String, String>> get _currencies => [
    {'code': 'BRL', 'name': 'Real Brasileiro', 'flag': '🇧🇷', 'symbol': r'R$'},
    {'code': 'USD', 'name': 'Dólar Americano', 'flag': '🇺🇸', 'symbol': 'US\$'},
    {'code': 'EUR', 'name': 'Euro', 'flag': '🇪🇺', 'symbol': '€'},
    {'code': 'GBP', 'name': 'Libra Esterlina', 'flag': '🇬🇧', 'symbol': '£'},
    {'code': 'NZD', 'name': 'Dólar Neozelandês', 'flag': '🇳🇿', 'symbol': 'NZ\$'},
    {'code': 'AED', 'name': 'Dirham dos EAU', 'flag': '🇦🇪', 'symbol': 'د.إ'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      UserModel user;
      if (widget.user != null) {
        user = widget.user!;
      } else {
        user = await _authService.getMe();
      }

      if (!mounted) return;
      setState(() {
        _selectedCurrency = user.baseCurrency;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedCurrency == null) return;

    setState(() {
      _isSaving = true;
      _message = null;
    });

    try {
      // 🔧 CORRIGIDO: Passa a moeda como argumento direto
      final updatedUser = await _authService.updateBaseCurrency(_selectedCurrency!);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Moeda base atualizada com sucesso!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      
      context.pop(updatedUser);
    } catch (e) {
      setState(() {
        _message = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _getCurrencyFlag(String code) {
    switch (code) {
      case 'BRL':
        return '🇧🇷';
      case 'USD':
        return '🇺🇸';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'NZD':
        return '🇳🇿';
      case 'AED':
        return '🇦🇪';
      default:
        return '💰';
    }
  }

  String _getCurrencySymbol(String code) {
    switch (code) {
      case 'BRL':
        return 'R\$';
      case 'USD':
        return 'US\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'NZD':
        return 'NZ\$';
      case 'AED':
        return 'د.إ';
      default:
        return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundSand,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundSand,
      appBar: AppBar(
        title: const Text('Moeda Base'),
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
            Center(
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
                  Icons.currency_exchange,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Título
            Center(
              child: Text(
                'Moeda Base',
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
                'Escolha a moeda principal do sistema',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Card do formulário
            Container(
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
                    'Selecione a moeda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista de moedas
                  ..._currencies.map((currency) {
                    final isSelected = _selectedCurrency == currency['code'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCurrency = currency['code'];
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.primaryTerracota.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? AppColors.primaryTerracota
                                  : AppColors.borderSand,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _getCurrencyFlag(currency['code']!),
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currency['code']!,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected 
                                            ? AppColors.primaryTerracota
                                            : AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currency['name']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                currency['symbol']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected 
                                      ? AppColors.primaryTerracota
                                      : AppColors.textMedium,
                                ),
                              ),
                              if (isSelected)
                                const Padding(
                                  padding: EdgeInsets.only(left: 12),
                                  child: Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                    size: 22,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Container informativo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppStyles.infoContainerDecoration,
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
                          'Moeda base',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Todos os valores serão convertidos e exibidos nesta moeda no dashboard principal.',
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
            ),
            
            const SizedBox(height: 24),
            
            // Botão salvar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: AppStyles.primaryButtonStyle,
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Salvar Moeda Base'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Mensagem de erro
            if (_message != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: AppStyles.errorContainerDecoration,
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
              ),
          ],
        ),
      ),
    );
  }
}