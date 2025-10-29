import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../services/payment_service.dart';
import '../../utils/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _notesController = TextEditingController();
  final ApiService _apiService = ApiService();
  final PaymentService _paymentService = PaymentService();

  String _selectedPaymentMethod = 'cash';
  bool _printReceipt = true;
  bool _emailReceipt = false;
  bool _smsReceipt = false;
  bool _isProcessing = false;
  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _cartItems = [];
  List<PaymentMethod> _availablePaymentMethods = [];
  List<PaymentMethod> _filteredPaymentMethods = [];
  bool _isRegisteredUser = false;

  // Discount variables
  final _discountCodeController = TextEditingController();
  String? _appliedDiscountCode;
  double _discountPercentage = 0.0;
  double _discountAmount = 0.0;
  bool _isValidatingDiscount = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
    _loadPaymentMethods();
  }

  Future<void> _loadCartItems() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Use API to get cart items
      final items = await _apiService.getCartItems();

      print('🔍 Checkout: Loaded ${items.length} items from API');
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        print('🔍 Checkout: Item $i: ${item.keys.toList()}');
        print('🔍 Checkout: Item $i totalAmount: ${item['totalAmount']}');
        print('🔍 Checkout: Item $i finalAmount: ${item['finalAmount']}');
        print('🔍 Checkout: Item $i price: ${item['price']}');
      }

      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load cart: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadCartItems,
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadPaymentMethods() async {
    try {
      await _paymentService.initialize();
      final methods = _paymentService.getAvailablePaymentMethods();

      // Check if user is registered (simulate based on email input)
      final isRegistered = _customerEmailController.text.isNotEmpty;

      setState(() {
        _availablePaymentMethods = methods;
        _isRegisteredUser = isRegistered;
        _filteredPaymentMethods =
            _getFilteredPaymentMethods(methods, isRegistered);
      });
    } catch (e) {
      debugPrint('Failed to load payment methods: $e');
    }
  }

  List<PaymentMethod> _getFilteredPaymentMethods(
      List<PaymentMethod> methods, bool isRegistered) {
    if (isRegistered) {
      // Registered users can use all payment methods
      return methods;
    } else {
      // Non-registered users can only use cash and bank transfer
      return methods
          .where(
              (method) => method.id == 'cash' || method.id == 'bank_transfer')
          .toList();
    }
  }

  void _updatePaymentMethods() {
    final isRegistered = _customerEmailController.text.isNotEmpty;
    setState(() {
      _isRegisteredUser = isRegistered;
      _filteredPaymentMethods =
          _getFilteredPaymentMethods(_availablePaymentMethods, isRegistered);

      // If current selected method is not available, select the first available one
      if (!_filteredPaymentMethods
          .any((method) => method.id == _selectedPaymentMethod)) {
        _selectedPaymentMethod = _filteredPaymentMethods.isNotEmpty
            ? _filteredPaymentMethods.first.id
            : 'cash';
      }
    });
  }

  // Mock discount codes
  final Map<String, Map<String, dynamic>> _discountCodes = {
    'WELCOME10': {
      'percentage': 10.0,
      'description': 'Welcome discount - 10% off'
    },
    'SAVE20': {'percentage': 20.0, 'description': 'Special offer - 20% off'},
    'FIRST15': {
      'percentage': 15.0,
      'description': 'First time buyer - 15% off'
    },
    'HEALTH5': {'percentage': 5.0, 'description': 'Health promotion - 5% off'},
  };

  Future<void> _applyDiscountCode() async {
    final code = _discountCodeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseEnterDiscountCode),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isValidatingDiscount = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    if (_discountCodes.containsKey(code)) {
      final discountData = _discountCodes[code]!;
      setState(() {
        _appliedDiscountCode = code;
        _discountPercentage = discountData['percentage'];
        _discountAmount = _subtotal * (_discountPercentage / 100);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${AppLocalizations.of(context)!.discountApplied} ${discountData['description']}'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidDiscountCode),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }

    setState(() {
      _isValidatingDiscount = false;
    });
  }

  void _removeDiscountCode() {
    setState(() {
      _appliedDiscountCode = null;
      _discountPercentage = 0.0;
      _discountAmount = 0.0;
      _discountCodeController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.discountCodeRemoved),
        backgroundColor: Colors.grey[600],
      ),
    );
  }

  double get _subtotal {
    print('🔍 Checkout: Calculating subtotal for ${_cartItems.length} items');
    double total = 0.0;

    for (int i = 0; i < _cartItems.length; i++) {
      final item = _cartItems[i];
      double itemAmount = 0.0;

      print('🔍 Checkout: Item $i keys: ${item.keys.toList()}');
      print(
          '🔍 Checkout: Item $i unitPrice: ${item['unitPrice']}, totalPrice: ${item['totalPrice']}, quantity: ${item['quantity']}');

      // Try direct amount fields first
      if (item['totalAmount'] != null) {
        itemAmount = (item['totalAmount'] as num).toDouble();
        print('🔍 Checkout: Item $i using totalAmount: $itemAmount');
      } else if (item['finalAmount'] != null) {
        itemAmount = (item['finalAmount'] as num).toDouble();
        print('🔍 Checkout: Item $i using finalAmount: $itemAmount');
      } else if (item['totalPrice'] != null) {
        itemAmount = (item['totalPrice'] as num).toDouble();
        print('🔍 Checkout: Item $i using totalPrice: $itemAmount');
      } else if (item['price'] != null) {
        itemAmount = (item['price'] as num).toDouble();
        print('🔍 Checkout: Item $i using price: $itemAmount');
      } else if (item['unitPrice'] != null && item['quantity'] != null) {
        // Calculate from unitPrice * quantity
        final unitPrice = (item['unitPrice'] as num).toDouble();
        final quantity = (item['quantity'] as num).toDouble();
        itemAmount = unitPrice * quantity;
        print(
            '🔍 Checkout: Item $i calculated from unitPrice * quantity: $unitPrice * $quantity = $itemAmount');
      } else {
        // Fallback: Use default price if no price data available
        final quantity = (item['quantity'] ?? 1) as num;
        itemAmount = 50.0 * quantity.toDouble(); // Default price of 50 per item
        print(
            '🔍 Checkout: Item $i using default price (50.0 * $quantity = $itemAmount)');
      }

      print('🔍 Checkout: Item $i final amount: $itemAmount');
      total += itemAmount;
    }

    print('🔍 Checkout: Final subtotal: $total');
    return total;
  }

  double get _itemDiscountAmount =>
      _cartItems.fold(0.0, (sum, item) => sum + (item['discount'] ?? 0.0));
  double get _totalDiscountAmount => _itemDiscountAmount + _discountAmount;
  double get _tax =>
      (_subtotal - _totalDiscountAmount) * 0.05; // 5% tax on discounted amount
  double get _total => _subtotal - _totalDiscountAmount + _tax;

  String _generateTransactionReference() {
    final now = DateTime.now();
    return 'TX-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  void _showPaymentSuccessDialog(String transactionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  AppTheme.primaryTeal.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.successGreen.withOpacity(0.2),
                        AppTheme.successGreen.withOpacity(0.05),
                      ],
                      center: Alignment.center,
                      radius: 1.0,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.successGreen.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 60,
                    color: AppTheme.successGreen,
                  ),
                ),

                const SizedBox(height: 24),

                // Success Title
                Text(
                  'Payment Successful!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successGreen,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Success Message
                Text(
                  AppLocalizations.of(context)!.paymentSuccessMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Transaction ID
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.primaryTeal.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            color: AppTheme.primaryTeal,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.transactionId,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryTeal,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        transactionId,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGray,
                            ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(); // Go back to market
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryTeal,
                          side: const BorderSide(color: AppTheme.primaryTeal),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.shopping_bag, size: 18),
                        label: Text(
                            AppLocalizations.of(context)!.continueShopping),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.successGreen,
                              AppTheme.successGreen.withOpacity(0.8)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.successGreen.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(context).pop(); // Go back to market
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.home, size: 18),
                          label: Text(AppLocalizations.of(context)!.goToHome),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _notesController.dispose();
    _discountCodeController.dispose();
    super.dispose();
  }

  String _getPaymentMethodName(String methodId) {
    final method = _availablePaymentMethods.firstWhere(
      (method) => method.id == methodId,
      orElse: () => PaymentMethod(
        id: methodId,
        name: methodId.toUpperCase(),
        icon: '💳',
        description: '',
        isAvailable: true,
      ),
    );
    return method.name;
  }

  Widget _buildDiscountCodeSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: AppTheme.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.discountCode,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_appliedDiscountCode != null) ...[
            // Applied discount display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.successGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.discountApplied,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successGreen,
                          ),
                        ),
                        Text(
                          '${AppLocalizations.of(context)!.codeDiscount}: $_appliedDiscountCode (${_discountPercentage.toInt()}% ${AppLocalizations.of(context)!.off})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _removeDiscountCode,
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.errorRed,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Discount code input
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _discountCodeController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.enterDiscountCode,
                    hintText: AppLocalizations.of(context)!.discountCodeHint,
                    prefixIcon: const Icon(Icons.confirmation_number),
                    border: const OutlineInputBorder(),
                    enabled: _appliedDiscountCode == null,
                  ),
                  enabled: _appliedDiscountCode == null,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _appliedDiscountCode == null
                        ? [
                            AppTheme.primaryTeal,
                            AppTheme.primaryTeal.withOpacity(0.8)
                          ]
                        : [Colors.grey, Colors.grey.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (_appliedDiscountCode == null
                              ? AppTheme.primaryTeal
                              : Colors.grey)
                          .withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed:
                      _appliedDiscountCode == null && !_isValidatingDiscount
                          ? _applyDiscountCode
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isValidatingDiscount
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.add, size: 18),
                  label: Text(_isValidatingDiscount
                      ? AppLocalizations.of(context)!.applying
                      : AppLocalizations.of(context)!.apply),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Available discount codes hint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[700],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.tryDiscountCodes,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.payment,
                color: AppTheme.primaryTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)!.paymentMethod,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // User registration status indicator
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isRegisteredUser
                ? AppTheme.successGreen.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isRegisteredUser
                  ? AppTheme.successGreen.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _isRegisteredUser ? Icons.verified_user : Icons.info_outline,
                color:
                    _isRegisteredUser ? AppTheme.successGreen : Colors.orange,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isRegisteredUser
                      ? 'Registered users can use all payment methods'
                      : 'Guest users can only use cash and bank transfer',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _isRegisteredUser
                            ? AppTheme.successGreen
                            : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _filteredPaymentMethods.map((method) {
              final isSelected = _selectedPaymentMethod == method.id;
              return Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryTeal.withOpacity(0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: RadioListTile<String>(
                  value: method.id,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedPaymentMethod = newValue!;
                    });
                  },
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryTeal.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          method.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? AppTheme.primaryTeal
                                        : AppTheme.darkGray,
                                  ),
                            ),
                            if (method.description.isNotEmpty)
                              Text(
                                method.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  activeColor: AppTheme.primaryTeal,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionRef = _generateTransactionReference();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.checkout,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_cart, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_cartItems.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCartItems,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _cartItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.primaryTeal.withOpacity(0.15),
                                  AppTheme.primaryTeal.withOpacity(0.05),
                                ],
                                center: Alignment.center,
                                radius: 1.0,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryTeal.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              size: 100,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            AppLocalizations.of(context)!.yourCartIsEmpty,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!
                                .addSomeMedicinesToGetStarted,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryTeal,
                                  AppTheme.primaryTeal.withOpacity(0.8)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryTeal.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              icon: const Icon(Icons.arrow_back, size: 20),
                              label: Text(
                                  AppLocalizations.of(context)!.backToCart),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: _loadCartItems,
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Transaction Summary
                                    _buildTransactionSummary(
                                        theme, transactionRef),
                                    const SizedBox(height: 24),

                                    // Order Details
                                    _buildOrderDetails(theme),
                                    const SizedBox(height: 24),

                                    // Customer Information
                                    _buildCustomerInformation(theme),
                                    const SizedBox(height: 24),

                                    // Discount Code Section
                                    _buildDiscountCodeSection(theme),
                                    const SizedBox(height: 24),

                                    // Payment Method Selection
                                    _buildPaymentMethodSelector(),
                                    const SizedBox(height: 24),

                                    // Receipt Options
                                    _buildReceiptOptions(theme),
                                    const SizedBox(height: 24),

                                    // Transaction Notes
                                    _buildTransactionNotes(theme),
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Bottom Summary and Checkout Button
                          _buildBottomCheckout(theme),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildTransactionSummary(ThemeData theme, String transactionRef) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryTeal.withOpacity(0.1),
            AppTheme.primaryTeal.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppTheme.primaryTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.transactionSummary,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.qr_code,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.referenceNumber,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        transactionRef,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey[600],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.dateTime,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateTime.now().toString().substring(0, 16),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetails(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  color: AppTheme.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.orderDetails,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Grouped medicine breakdown
          ..._buildGroupedMedicines(theme),

          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey[300]!,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pricing summary
          _buildPricingSummary(theme),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedMedicines(ThemeData theme) {
    // Extract all medicines from all items
    List<Map<String, dynamic>> allMedicines = [];

    print('🔍 Checkout: Processing ${_cartItems.length} cart items');

    for (var item in _cartItems) {
      print(
          '🔍 Checkout: Item type: ${item['type']}, has medicines: ${item['medicines'] != null}');

      if (item['type'] == 'invoice' && item['medicines'] != null) {
        // Add medicines from invoice
        final medicines = item['medicines'] as List;
        print(
            '🔍 Checkout: Processing ${medicines.length} medicines from invoice');

        for (var medicine in medicines) {
          print(
              '🔍 Checkout: Medicine: ${medicine['name']}, Price: ${medicine['price']}, Quantity: ${medicine['quantity']}');

          allMedicines.add({
            ...medicine,
            'sourceInvoice': item['invoiceNumber'] ?? item['transactionNumber'],
            'sourcePharmacy': item['pharmacyName'] ?? 'Pharmacy',
            // Ensure price is available
            'price': medicine['price'] ?? medicine['unitPrice'] ?? 50.0,
          });
        }
      } else {
        // Add individual medicine
        print(
            '🔍 Checkout: Adding individual medicine: ${item['name']}, Price: ${item['price']}');
        allMedicines.add({
          ...item,
          'sourceInvoice': 'Individual',
          'sourcePharmacy': 'Direct',
          // Ensure price is available
          'price': item['price'] ?? item['unitPrice'] ?? 50.0,
        });
      }
    }

    print('🔍 Checkout: Total medicines extracted: ${allMedicines.length}');

    // Group medicines by name and form
    Map<String, List<Map<String, dynamic>>> groupedMedicines = {};

    for (var medicine in allMedicines) {
      final String key =
          '${medicine['name']}_${medicine['form']}_${medicine['genericName']}';

      if (!groupedMedicines.containsKey(key)) {
        groupedMedicines[key] = [];
      }
      groupedMedicines[key]!.add(medicine);
    }

    // Build widgets for grouped medicines
    List<Widget> widgets = [];

    groupedMedicines.forEach((key, medicines) {
      if (medicines.length == 1) {
        // Single medicine - show as individual
        widgets.add(_buildMedicineItemBreakdown(medicines.first, theme));
      } else {
        // Multiple same medicines - show as grouped
        widgets.add(_buildGroupedMedicineItem(medicines, theme));
      }
    });

    return widgets;
  }

  Widget _buildGroupedMedicineItem(
      List<Map<String, dynamic>> medicines, ThemeData theme) {
    // Calculate total quantity and price
    int totalQuantity = medicines.fold(
        0, (sum, medicine) => sum + ((medicine['quantity'] ?? 1) as int));
    double totalPrice = medicines.fold(
        0.0,
        (sum, medicine) =>
            sum +
            ((medicine['price'] ?? medicine['unitPrice'] ?? 0.0) *
                (medicine['quantity'] ?? 1)));

    // Get sources
    Set<String> sources =
        medicines.map((m) => m['sourceInvoice'] as String).toSet();
    String sourceText = sources.length == 1
        ? 'From ${medicines.first['sourcePharmacy']}'
        : 'From ${sources.length} sources';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryTeal.withOpacity(0.05),
            AppTheme.primaryTeal.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicine Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication,
                  color: AppTheme.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicines.first['name'] ??
                          medicines.first['medicineName'] ??
                          medicines.first['genericName'] ??
                          'Unknown Medicine',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    Text(
                      '${medicines.first['genericName'] ?? medicines.first['activeIngredient'] ?? 'N/A'} • ${medicines.first['form'] ?? 'Tablet'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      sourceText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Qty: $totalQuantity',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  Text(
                    '\$${totalPrice.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Breakdown of sources
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Breakdown:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                ...medicines
                    .map((medicine) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text(
                                '${medicine['sourceInvoice']}: ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${medicine['quantity']} × \$${(medicine['price'] ?? medicine['unitPrice'] ?? 0.0).toStringAsFixed(2)} = \$${((medicine['price'] ?? medicine['unitPrice'] ?? 0.0) * (medicine['quantity'] ?? 1)).toStringAsFixed(2)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.darkGray,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineBreakdown(Map<String, dynamic> item, ThemeData theme) {
    final String itemType = item['type'] ?? 'medicine';

    if (itemType == 'invoice') {
      return _buildInvoiceBreakdown(item, theme);
    } else {
      return _buildMedicineItemBreakdown(item, theme);
    }
  }

  Widget _buildMedicineItemBreakdown(
      Map<String, dynamic> item, ThemeData theme) {
    final itemTotal =
        (item['price'] ?? item['unitPrice'] ?? 50.0) * (item['quantity'] ?? 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[50]!,
            Colors.grey[100]!.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item['imageUrl'] != null
                      ? Image.network(
                          item['imageUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.primaryTeal.withOpacity(0.1),
                              child: Icon(
                                Icons.medication,
                                color: AppTheme.primaryTeal,
                                size: 24,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppTheme.primaryTeal.withOpacity(0.1),
                          child: Icon(
                            Icons.medication,
                            color: AppTheme.primaryTeal,
                            size: 24,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? item['medicineName'] ?? 'N/A',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['genericName']} • ${item['form']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${item['manufacturer']} • ${item['packSize']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Qty: ${item['quantity'] ?? 1}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${(item['price'] ?? item['unitPrice'] ?? 50.0).toStringAsFixed(2)} each',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${itemTotal.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineItemBreakdownOriginal(
      Map<String, dynamic> item, ThemeData theme) {
    final itemTotal = (item['price'] ?? 0.0) * (item['quantity'] ?? 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[50]!,
            Colors.grey[100]!.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item['imageUrl'] != null
                      ? Image.network(
                          item['imageUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.primaryTeal.withOpacity(0.1),
                              child: Icon(
                                Icons.medication,
                                color: AppTheme.primaryTeal,
                                size: 24,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppTheme.primaryTeal.withOpacity(0.1),
                          child: Icon(
                            Icons.medication,
                            color: AppTheme.primaryTeal,
                            size: 24,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'] ?? 'N/A',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGray,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item['genericName']} • ${item['form']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${item['manufacturer']} • ${item['packSize']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Qty: ${item['quantity'] ?? 1}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${(item['price'] ?? 0.0).toStringAsFixed(2)} each',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${itemTotal.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Batch: ${item['batchNumber']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Exp: ${item['expiryDate']?.substring(0, 10) ?? 'N/A'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceBreakdown(Map<String, dynamic> item, ThemeData theme) {
    final double totalAmount = item['totalAmount'] ?? 0.0;
    final double discount = item['discount'] ?? 0.0;
    final double finalAmount = item['finalAmount'] ?? totalAmount;
    final int medicineCount = item['medicines']?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryTeal.withOpacity(0.05),
            AppTheme.primaryTeal.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppTheme.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['invoiceNumber'] ?? 'Invoice',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    Text(
                      item['pharmacyName'] ?? 'Pharmacy',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${finalAmount.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Invoice Details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.invoiceDate,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      item['date'] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.invoiceType,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      item['invoiceType'] == 'complete'
                          ? AppLocalizations.of(context)!.completeInvoice
                          : AppLocalizations.of(context)!.partialInvoice,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.medicines,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '$medicineCount ${AppLocalizations.of(context)!.items}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (discount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.discount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${discount}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Medicines List (Collapsible)
          ExpansionTile(
            title: Text(
              AppLocalizations.of(context)!.medicinesInInvoice,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryTeal,
              ),
            ),
            children: [
              ...item['medicines']?.map<Widget>((medicine) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getFormIcon(medicine['form'] ?? 'Tablet'),
                            color: AppTheme.primaryTeal,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medicine['name'] ?? '',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  medicine['manufacturer'] ?? '',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${medicine['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList() ??
                  [],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSummary(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${AppLocalizations.of(context)!.subtotal}:',
                style: theme.textTheme.bodyMedium),
            Text('\$${_subtotal.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium),
          ],
        ),
        if (_itemDiscountAmount > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${AppLocalizations.of(context)!.itemDiscount}:',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.successGreen)),
              Text('-\$${_itemDiscountAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.successGreen)),
            ],
          ),
        ],
        if (_discountAmount > 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${AppLocalizations.of(context)!.codeDiscountPercent} (${_discountPercentage.toInt()}%):',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.successGreen)),
              Text('-\$${_discountAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppTheme.successGreen)),
            ],
          ),
        ],
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${AppLocalizations.of(context)!.taxPercent}:',
                style: theme.textTheme.bodyMedium),
            Text('\$${_tax.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${AppLocalizations.of(context)!.total}:',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${_total.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTeal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerInformation(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Information (Optional)',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerNameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.customerName,
              hintText: 'Enter customer name',
              prefixIcon: const Icon(Icons.person_outline),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerPhoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.customerPhone,
              hintText: 'Enter phone number',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 10) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerEmailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              _updatePaymentMethods();
            },
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.emailAddressOptional,
              hintText: AppLocalizations.of(context)!.enterEmailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              suffixIcon: _customerEmailController.text.isNotEmpty
                  ? Icon(
                      Icons.verified_user,
                      color: AppTheme.successGreen,
                      size: 20,
                    )
                  : Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
              border: const OutlineInputBorder(),
              helperText: AppLocalizations.of(context)!.emailHelperText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptOptions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Receipt Options',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _printReceipt,
            onChanged: (value) {
              setState(() {
                _printReceipt = value ?? false;
              });
            },
            title: Row(
              children: [
                const Icon(Icons.print),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.printReceipt),
              ],
            ),
            activeColor: AppTheme.primaryTeal,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: _emailReceipt,
            onChanged: (value) {
              setState(() {
                _emailReceipt = value ?? false;
              });
            },
            title: Row(
              children: [
                const Icon(Icons.email),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.emailReceipt),
              ],
            ),
            activeColor: AppTheme.primaryTeal,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: _smsReceipt,
            onChanged: (value) {
              setState(() {
                _smsReceipt = value ?? false;
              });
            },
            title: Row(
              children: [
                const Icon(Icons.sms),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.smsReceipt),
              ],
            ),
            activeColor: AppTheme.primaryTeal,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionNotes(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppLocalizations.of(context)!.transactionNotes} (Optional)',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add special instructions or notes...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckout(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surface.withOpacity(0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.payment,
                        color: AppTheme.primaryTeal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.totalAmount,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGray,
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${_total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryTeal,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppTheme.primaryTeal.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryTeal,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: Text(AppLocalizations.of(context)!.backToCart),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryTeal,
                        AppTheme.primaryTeal.withOpacity(0.8)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryTeal.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed:
                        _isProcessing ? null : _processPaymentWithBackend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isProcessing
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.payment, size: 18),
                    label: Text(
                      _isProcessing
                          ? AppLocalizations.of(context)!.processing
                          : AppLocalizations.of(context)!.confirmPayment,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Add checkout notification to home screen
  Future<void> _addCheckoutNotificationToHome(String transactionId) async {
    try {
      // Calculate total items and amount
      num totalItems = 0;
      double totalAmount = 0;
      List<String> medicineNames = [];

      for (var item in _cartItems) {
        final List<Map<String, dynamic>> medicines;

        if (item['medicines'] != null && item['medicines'] is List) {
          medicines = List<Map<String, dynamic>>.from(item['medicines']);
        } else {
          medicines = [item];
        }

        for (var medicine in medicines) {
          totalItems += medicine['quantity'] ?? 1;
          totalAmount += (medicine['price'] ?? medicine['unitPrice'] ?? 50.0) *
              (medicine['quantity'] ?? 1);
          medicineNames
              .add(medicine['name'] ?? medicine['medicineName'] ?? 'Unknown');
        }
      }

      // Create checkout notification for home screen
      final checkoutNotification = {
        'type': 'checkout',
        'title': 'Checkout Completed',
        'message':
            'Invoice checkout completed! $totalItems items sold for \$${totalAmount.toStringAsFixed(2)}',
        'transactionId': transactionId,
        'totalItems': totalItems,
        'totalAmount': totalAmount,
        'medicineNames': medicineNames.take(3).join(', '),
        'priority': 'high',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Send to API
      await _apiService.createNotification(checkoutNotification);

      print(
          '🔔 Checkout notification sent to home: $totalItems items, \$${totalAmount.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ Error sending checkout notification to home: $e');
    }
  }

  // Send sale notification to home screen
  Future<void> _sendSaleNotificationToHome(String transactionId) async {
    try {
      // Calculate total items sold
      num totalItems = 0;
      double totalAmount = 0;
      List<String> medicineNames = [];

      for (var item in _cartItems) {
        final List<Map<String, dynamic>> medicines;

        if (item['medicines'] != null && item['medicines'] is List) {
          medicines = List<Map<String, dynamic>>.from(item['medicines']);
        } else {
          medicines = [item];
        }

        for (var medicine in medicines) {
          totalItems += medicine['quantity'] ?? 1;
          totalAmount += (medicine['price'] ?? 0) * (medicine['quantity'] ?? 1);
          medicineNames.add(medicine['name'] ?? 'Unknown');
        }
      }

      // Create sale notification
      final saleNotification = {
        'type': 'sale',
        'title': 'Sale Completed',
        'message':
            'Invoice sold successfully! $totalItems items for \$${totalAmount.toStringAsFixed(2)}',
        'transactionId': transactionId,
        'totalItems': totalItems,
        'totalAmount': totalAmount,
        'medicineNames':
            medicineNames.take(3).join(', '), // Show first 3 medicines
        'priority': 'medium',
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Send to API
      await _apiService.createNotification(saleNotification);

      // Show immediate notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '💰 Sale Completed: $totalItems items sold for \$${totalAmount.toStringAsFixed(2)}'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushNamed('/sales');
              },
            ),
          ),
        );
      }

      print(
          '🔔 Sale notification sent to home: $totalItems items, \$${totalAmount.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ Error sending sale notification to home: $e');
    }
  }

  Future<void> _sendNotifications(String transactionId) async {
    try {
      print('🔔 Checkout: Sending notifications...');

      // Send sale notification to home screen
      await _sendSaleNotificationToHome(transactionId);

      // 1. Send Sale Notification (إشعار بيع)
      for (var item in _cartItems) {
        final List<Map<String, dynamic>> medicines;

        if (item['medicines'] != null && item['medicines'] is List) {
          medicines = List<Map<String, dynamic>>.from(item['medicines']);
        } else {
          // Handle single medicine
          medicines = [item];
        }

        for (var medicine in medicines) {
          // Get medicine details
          final dynamic tempMedicineId =
              medicine['id']?['_id'] ?? medicine['medicineId'];
          final String? medicineId =
              (tempMedicineId is Map && tempMedicineId.containsKey('_id'))
                  ? tempMedicineId['_id']?.toString()
                  : tempMedicineId?.toString();

          if (medicineId == null) continue;

          try {
            // Get medicine details from backend
            final medicineData = await _apiService.getMedicineById(medicineId);
            final currentStock =
                medicineData['quantity'] ?? medicineData['stock'] ?? 0;

            // 1. Sale Notification - إشعار بيع
            await _apiService.createNotification({
              'type': 'sale',
              'title': 'Sale Completed',
              'message': 'Someone purchased ${medicine['name'] ?? 'medicine'}',
              'transactionId': transactionId,
              'medicineId': medicineId,
              'medicineName': medicine['name'],
              'quantity': medicine['quantity'] ?? 1,
              'amount': _total,
              'priority': 'medium',
              'timestamp': DateTime.now().toIso8601String(),
            });

            // Show immediate sale notification
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('💰 Sale: ${medicine['name']} sold successfully!'),
                  backgroundColor: AppTheme.successGreen,
                  duration: const Duration(seconds: 3),
                ),
              );
            }

            // 2. Low Stock Notification - إشعار مخزون منخفض
            if (currentStock < 10) {
              await _apiService.createNotification({
                'type': 'low_stock',
                'title': 'Low Stock Alert',
                'message':
                    '${medicine['name'] ?? 'Medicine'} is running low on stock ($currentStock remaining)',
                'medicineId': medicineId,
                'medicineName': medicine['name'],
                'currentStock': currentStock,
                'threshold': 10,
                'priority': currentStock <= 3 ? 'high' : 'medium',
                'timestamp': DateTime.now().toIso8601String(),
              });

              // Show immediate low stock notification
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '⚠️ Low Stock: ${medicine['name']} (${currentStock} remaining)'),
                    backgroundColor: Colors.orange,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }

              print('🔔 Low stock notification sent for ${medicine['name']}');
            }
          } catch (e) {
            print('❌ Error checking medicine stock: $e');
          }
        }
      }

      print('🔔 All notifications sent successfully');
    } catch (e) {
      print('❌ Error sending notifications: $e');
      // Don't fail the checkout if notifications fail
    }
  }

  Future<void> _processPaymentWithBackend() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      print('💳 Checkout: Starting payment process...');

      // Extract medicines from cart items with proper validation
      List<Map<String, dynamic>> medicines = [];
      for (var item in _cartItems) {
        if (item['medicines'] != null && item['medicines'] is List) {
          // Handle invoice with multiple medicines
          for (var medicine in item['medicines']) {
            final dynamic tempMedicineId =
                medicine['id']?['_id'] ?? medicine['medicineId'];
            final String? medicineId =
                (tempMedicineId is Map && tempMedicineId.containsKey('_id'))
                    ? tempMedicineId['_id']?.toString()
                    : tempMedicineId?.toString();
            final quantity = medicine['quantity'] ?? 1;
            final unitPrice = medicine['price'] ?? medicine['unitPrice'] ?? 0.0;

            // Validate required fields
            if (medicineId == null || medicineId.toString().isEmpty) {
              throw Exception('Medicine ID is required for all items');
            }

            if (quantity < 1) {
              throw Exception('Quantity must be at least 1 for all items');
            }

            medicines.add({
              'medicineId': medicineId,
              'quantity': quantity,
              'unitPrice': unitPrice,
            });
          }
        } else {
          // Handle individual medicine
          final dynamic tempMedicineId = item['medicineId'];
          final String? medicineId =
              (tempMedicineId is Map && tempMedicineId.containsKey('_id'))
                  ? tempMedicineId['_id']?.toString()
                  : tempMedicineId?.toString();
          final quantity = item['quantity'] ?? 1;
          final unitPrice = item['unitPrice'] ?? item['price'] ?? 0.0;

          // Validate required fields
          if (medicineId == null || medicineId.toString().isEmpty) {
            throw Exception('Medicine ID is required for all items');
          }

          if (quantity < 1) {
            throw Exception('Quantity must be at least 1 for all items');
          }

          medicines.add({
            'medicineId': medicineId,
            'quantity': quantity,
            'unitPrice': unitPrice,
          });
        }
      }

      // Validate that we have at least one medicine
      if (medicines.isEmpty) {
        throw Exception('No medicines found in cart');
      }

      print(
          '💳 Checkout: Prepared ${medicines.length} medicines for transaction');

      // Create transaction data according to backend requirements
      final transactionData = {
        'transactionType': 'sale', // Required
        'description': 'Sale transaction from checkout', // Optional
        'items': medicines, // Required - Array of medicines
        'customerName': _customerNameController.text.trim().isNotEmpty
            ? _customerNameController.text.trim()
            : null, // Optional
        'customerPhone': _customerPhoneController.text.trim().isNotEmpty
            ? _customerPhoneController.text.trim()
            : null, // Optional
        'paymentMethod': _selectedPaymentMethod, // Optional
        'tax': _tax, // Optional
        'discount': _discountAmount, // Optional
        'status': 'completed' // Optional
      };

      print('💳 Checkout: Creating transaction in backend...');
      print('💳 Transaction data: ${transactionData}');

      // Create transaction in backend
      final result = await _apiService.createTransaction(transactionData);

      print('💳 Checkout: Transaction created successfully');
      print('💳 Transaction ID: ${result['data']['_id']}');

      // Remove the original transaction from Market (if it exists)
      // This prevents the transaction from appearing in Market after checkout
      final originalTransactionId = _cartItems.isNotEmpty
          ? _cartItems.first['_id'] ?? _cartItems.first['transactionId']
          : null;

      if (originalTransactionId != null) {
        print(
            '🗑️ Checkout: Removing original transaction from Market: $originalTransactionId');
        try {
          await _apiService.removeFromCart(originalTransactionId);
          print('✅ Checkout: Original transaction removed from Market');
        } catch (e) {
          print(
              '⚠️ Checkout: Failed to remove original transaction from Market: $e');
          // Don't fail the checkout if this fails
        }
      }

      // Send notifications after successful checkout
      await _sendNotifications(result['data']['_id'] ?? 'Unknown');

      // Add local notification to home screen
      await _addCheckoutNotificationToHome(result['data']['_id'] ?? 'Unknown');

      // Clear cart after successful transaction
      await _apiService.clearCart();

      print('💳 Checkout: Cart cleared successfully');

      if (mounted) {
        // Show success dialog
        _showPaymentSuccessDialogNew(result['data']['_id'] ?? 'Unknown');
      }
    } catch (e) {
      print('❌ Checkout: Payment error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment error: $e'),
            backgroundColor: AppTheme.errorRed,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _processPaymentWithBackend,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showPaymentSuccessDialogNew(String transactionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          _PaymentSuccessDialogNew(transactionId: transactionId),
    );
  }

  Widget _PaymentSuccessDialogNew({required String transactionId}) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 28),
          SizedBox(width: 8),
          Text('Payment Successful!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transaction completed successfully!'),
          SizedBox(height: 8),
          Text('Transaction ID:',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Text(transactionId, style: TextStyle(fontFamily: 'monospace')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop(); // Go back to previous screen
          },
          child: Text('OK'),
        ),
      ],
    );
  }

  IconData _getFormIcon(String form) {
    switch (form.toLowerCase()) {
      case 'tablet':
        return Icons.medication;
      case 'capsule':
        return Icons.medication_liquid;
      case 'syrup':
        return Icons.local_drink;
      case 'injection':
        return Icons.colorize;
      case 'cream':
        return Icons.healing;
      case 'ointment':
        return Icons.healing;
      case 'drops':
        return Icons.water_drop;
      case 'inhaler':
        return Icons.air;
      case 'patch':
        return Icons.medical_services;
      case 'powder':
        return Icons.scatter_plot;
      default:
        return Icons.medication;
    }
  }
}
