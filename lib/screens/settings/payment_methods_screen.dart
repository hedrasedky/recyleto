import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:recyleto_app/l10n/app_localizations.dart';

import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderNameController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final ApiService _apiService = ApiService();

  String _selectedPaymentType = 'card';
  bool _isDefault = false;
  bool _isLoading = false;

  List<Map<String, dynamic>> _paymentMethods = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardholderNameController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      await _apiService.initialize();

      // Load payment methods from API
      final paymentMethods = await _apiService.getPaymentMethods();

      setState(() {
        _paymentMethods = paymentMethods;
      });
    } catch (e) {
      print('Error loading payment methods: $e');

      // Fallback to local storage if API fails
      try {
        final prefs = await SharedPreferences.getInstance();
        final paymentMethodsJson = prefs.getStringList('payment_methods') ?? [];

        setState(() {
          if (paymentMethodsJson.isEmpty) {
            // Add sample data if no data exists
            _paymentMethods = [
              {
                'id': '1',
                'type': 'card',
                'cardNumber': '**** **** **** 1234',
                'cardholderName': 'John Doe',
                'expiryDate': '12/25',
                'isDefault': true,
                'bankName': 'Visa',
              },
              {
                'id': '2',
                'type': 'bank',
                'bankName': 'Chase Bank',
                'accountNumber': '****1234',
                'routingNumber': '****5678',
                'isDefault': false,
              },
            ];
            // Save sample data
            _savePaymentMethods();
          } else {
            _paymentMethods = paymentMethodsJson.map((json) {
              return Map<String, dynamic>.from(jsonDecode(json));
            }).toList();
          }
        });
      } catch (localError) {
        print('Error loading from local storage: $localError');
      }
    }
  }

  Future<void> _savePaymentMethods() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paymentMethodsJson =
          _paymentMethods.map((method) => jsonEncode(method)).toList();
      await prefs.setStringList('payment_methods', paymentMethodsJson);
    } catch (e) {
      print('Error saving payment methods: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.paymentMethods),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        foregroundColor: AppTheme.primaryTeal,
        actions: [
          IconButton(
            onPressed: _showAddPaymentDialog,
            icon: const Icon(Icons.add),
            tooltip: AppLocalizations.of(context)!.addNewCard,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 24),

            // Payment Methods List
            Text(
              AppLocalizations.of(context)!.paymentMethods,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
            ),
            const SizedBox(height: 16),

            if (_paymentMethods.isEmpty)
              _buildEmptyState()
            else
              ..._paymentMethods
                  .map((method) => _buildPaymentMethodCard(method)),

            const SizedBox(height: 24),

            // Payment Statistics
            _buildPaymentStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryTeal.withOpacity(0.1),
            AppTheme.lightTeal.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payment,
                  color: AppTheme.primaryTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.paymentMethods,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.paymentMethods,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkGray.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(AppLocalizations.of(context)!.paymentMethods,
                  '${_paymentMethods.length}', Icons.credit_card),
              const SizedBox(width: 24),
              _buildStatItem(
                  AppLocalizations.of(context)!.setAsDefault,
                  _paymentMethods
                      .where((m) => m['isDefault'] == true)
                      .length
                      .toString(),
                  Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryTeal, size: 16),
        const SizedBox(width: 8),
        Text(
          '$value $label',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.darkGray.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(
            Icons.payment_outlined,
            size: 64,
            color: AppTheme.darkGray.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.paymentMethods,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.paymentMethods,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGray.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddPaymentDialog,
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addNewCard),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isCard = method['type'] == 'card';
    final isDefault = method['isDefault'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDefault ? AppTheme.primaryTeal : Colors.grey.shade300,
          width: isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _editPaymentMethod(method),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCard
                      ? AppTheme.primaryTeal.withOpacity(0.1)
                      : AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCard ? Icons.credit_card : Icons.account_balance,
                  color: isCard ? AppTheme.primaryTeal : AppTheme.successGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isCard ? method['cardNumber'] : method['bankName'],
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkGray,
                                  ),
                        ),
                        if (isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: TextStyle(
                                color: AppTheme.primaryTeal,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCard
                          ? '${method['cardholderName']} • Expires ${method['expiryDate']}'
                          : 'Account ending in ${method['accountNumber']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.darkGray.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, method),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'set_default',
                    child: Row(
                      children: [
                        Icon(Icons.star, size: 16),
                        SizedBox(width: 8),
                        Text('Set as Default'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: AppTheme.darkGray.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Statistics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Transactions',
                  '\$12,450',
                  Icons.trending_up,
                  AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'This Month',
                  '\$2,340',
                  Icons.calendar_month,
                  AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.darkGray.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addNewCard),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Payment Type Selection
                DropdownButtonFormField<String>(
                  value: _selectedPaymentType,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.paymentMethods,
                    border: const OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'card', child: Text('Credit/Debit Card')),
                    DropdownMenuItem(
                        value: 'bank', child: Text('Bank Account')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                if (_selectedPaymentType == 'card') ...[
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      hintText: '1234 5678 9012 3456',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      CardNumberInputFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Card number is required';
                      }
                      final cleanValue = value.replaceAll(' ', '');
                      if (cleanValue.length < 16) {
                        return 'Card number must be 16 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _expiryDateController,
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date',
                            hintText: 'MM/YY',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_month),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            ExpiryDateInputFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Expiry date is required';
                            }
                            if (value.length < 5) {
                              return 'Invalid expiry date';
                            }

                            // Check if it's in MM/YY format
                            final parts = value.split('/');
                            if (parts.length != 2) {
                              return 'Invalid format (MM/YY)';
                            }

                            final month = int.tryParse(parts[0]);
                            final year = int.tryParse(parts[1]);

                            if (month == null || year == null) {
                              return 'Invalid date';
                            }

                            if (month < 1 || month > 12) {
                              return 'Month must be 01-12';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            hintText: '123',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.security),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'CVV is required';
                            }
                            if (value.length < 3) {
                              return 'CVV must be 3 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cardholderNameController,
                    decoration: const InputDecoration(
                      labelText: 'Cardholder Name',
                      hintText: 'John Doe',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cardholder name is required';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  TextFormField(
                    controller: _bankNameController,
                    decoration: const InputDecoration(
                      labelText: 'Bank Name',
                      hintText: 'Chase Bank',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bank name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _accountNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Account Number',
                      hintText: '1234567890',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Account number is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _routingNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Routing Number',
                      hintText: '123456789',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.route),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Routing number is required';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Set as default payment method'),
                  value: _isDefault,
                  onChanged: (value) {
                    setState(() {
                      _isDefault = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addPaymentMethod,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryTeal,
              foregroundColor: Colors.white,
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
                : const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addPaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.initialize();

      final paymentData = <String, dynamic>{
        'type': _selectedPaymentType,
        'isDefault': _isDefault,
      };

      if (_selectedPaymentType == 'card') {
        final cardNumber = _cardNumberController.text.replaceAll(' ', '');
        final lastFour = cardNumber.length >= 4
            ? cardNumber.substring(cardNumber.length - 4)
            : '****';
        paymentData.addAll({
          'cardNumber': '**** **** **** $lastFour',
          'cardholderName': _cardholderNameController.text,
          'expiryDate': _expiryDateController.text,
          'bankName': 'Visa',
        });
      } else {
        final accountNumber = _accountNumberController.text;
        final routingNumber = _routingNumberController.text;
        final lastFourAccount = accountNumber.length >= 4
            ? accountNumber.substring(accountNumber.length - 4)
            : '****';
        final lastFourRouting = routingNumber.length >= 4
            ? routingNumber.substring(routingNumber.length - 4)
            : '****';

        paymentData.addAll({
          'bankName': _bankNameController.text,
          'accountNumber': '****$lastFourAccount',
          'routingNumber': '****$lastFourRouting',
        });
      }

      // Add payment method via API
      final newMethod = await _apiService.addPaymentMethod(paymentData);

      setState(() {
        if (_isDefault) {
          // Remove default from other methods
          for (var method in _paymentMethods) {
            method['isDefault'] = false;
          }
        }
        _paymentMethods.add(newMethod);
        _isLoading = false;
      });

      Navigator.of(context).pop();
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment method added successfully'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Fallback to local storage
      final newMethod = <String, dynamic>{
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': _selectedPaymentType,
        'isDefault': _isDefault,
      };

      if (_selectedPaymentType == 'card') {
        final cardNumber = _cardNumberController.text.replaceAll(' ', '');
        final lastFour = cardNumber.length >= 4
            ? cardNumber.substring(cardNumber.length - 4)
            : '****';
        newMethod.addAll({
          'cardNumber': '**** **** **** $lastFour',
          'cardholderName': _cardholderNameController.text,
          'expiryDate': _expiryDateController.text,
          'bankName': 'Visa',
        });
      } else {
        final accountNumber = _accountNumberController.text;
        final routingNumber = _routingNumberController.text;
        final lastFourAccount = accountNumber.length >= 4
            ? accountNumber.substring(accountNumber.length - 4)
            : '****';
        final lastFourRouting = routingNumber.length >= 4
            ? routingNumber.substring(routingNumber.length - 4)
            : '****';

        newMethod.addAll({
          'bankName': _bankNameController.text,
          'accountNumber': '****$lastFourAccount',
          'routingNumber': '****$lastFourRouting',
        });
      }

      setState(() {
        if (_isDefault) {
          // Remove default from other methods
          for (var method in _paymentMethods) {
            method['isDefault'] = false;
          }
        }
        _paymentMethods.add(newMethod);
      });

      // Save to local storage
      await _savePaymentMethods();

      Navigator.of(context).pop();
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment method added locally: ${e.toString()}'),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
    }
  }

  void _editPaymentMethod(Map<String, dynamic> method) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit functionality coming soon'),
        backgroundColor: AppTheme.warningOrange,
      ),
    );
  }

  void _handleMenuAction(String action, Map<String, dynamic> method) async {
    switch (action) {
      case 'edit':
        _editPaymentMethod(method);
        break;
      case 'set_default':
        try {
          await _apiService.initialize();
          await _apiService.setDefaultPaymentMethod(method['id']);

          setState(() {
            for (var m in _paymentMethods) {
              m['isDefault'] = false;
            }
            method['isDefault'] = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Default payment method updated'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        } catch (e) {
          // Fallback to local storage
          setState(() {
            for (var m in _paymentMethods) {
              m['isDefault'] = false;
            }
            method['isDefault'] = true;
          });
          await _savePaymentMethods();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Default payment method updated locally: ${e.toString()}'),
              backgroundColor: AppTheme.warningOrange,
            ),
          );
        }
        break;
      case 'delete':
        _deletePaymentMethod(method);
        break;
    }
  }

  void _deletePaymentMethod(Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content:
            const Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.initialize();
                await _apiService.deletePaymentMethod(method['id']);

                setState(() {
                  _paymentMethods.removeWhere((m) => m['id'] == method['id']);
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment method deleted'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              } catch (e) {
                // Fallback to local storage
                setState(() {
                  _paymentMethods.removeWhere((m) => m['id'] == method['id']);
                });
                await _savePaymentMethods();

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Payment method deleted locally: ${e.toString()}'),
                    backgroundColor: AppTheme.warningOrange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _cardNumberController.clear();
    _expiryDateController.clear();
    _cvvController.clear();
    _cardholderNameController.clear();
    _bankNameController.clear();
    _accountNumberController.clear();
    _routingNumberController.clear();
    _isDefault = false;
  }
}

// Custom input formatters for card fields
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Remove any non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length <= 16) {
      final buffer = StringBuffer();
      for (int i = 0; i < digitsOnly.length; i++) {
        if (i > 0 && i % 4 == 0) {
          buffer.write(' ');
        }
        buffer.write(digitsOnly[i]);
      }
      final formatted = buffer.toString();
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return oldValue;
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Remove any non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length <= 4) {
      String formatted = digitsOnly;

      if (digitsOnly.length >= 2) {
        formatted = '${digitsOnly.substring(0, 2)}/${digitsOnly.substring(2)}';
      }

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return oldValue;
  }
}
