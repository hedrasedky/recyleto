import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  Future<void> _loadCartItems() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Use API to get cart items
      final allItems = await _apiService.getCartItems();

      print('🛒 CartScreen: Received ${allItems.length} items from API');
      for (int i = 0; i < allItems.length; i++) {
        print('🛒 CartScreen: Item $i: ${allItems[i]}');
      }

      // Filter to show only recent items (last 24 hours) to avoid showing old transactions
      final now = DateTime.now();
      final items = allItems.where((item) {
        final createdAt = item['createdAt'] ?? item['updatedAt'];
        if (createdAt == null) return false;

        final itemDate = DateTime.parse(createdAt);
        final hoursDiff = now.difference(itemDate).inHours;

        print(
            '🛒 CartScreen: Item ${item['medicineName']} created ${hoursDiff} hours ago');
        return hoursDiff <= 24; // Only show items from last 24 hours
      }).toList();

      print(
          '🛒 CartScreen: Filtered to ${items.length} recent items (last 24 hours)');

      // Group items by transaction to show complete invoices
      final Map<String, List<Map<String, dynamic>>> groupedByTransaction = {};
      for (var item in items) {
        final transactionId =
            item['transactionId'] ?? item['transactionNumber'] ?? 'unknown';
        if (!groupedByTransaction.containsKey(transactionId)) {
          groupedByTransaction[transactionId] = [];
        }
        groupedByTransaction[transactionId]!.add(item);
      }

      // Convert grouped items to invoice format
      final invoiceItems = groupedByTransaction.entries.map((entry) {
        final transactionId = entry.key;
        final items = entry.value;
        final firstItem = items.first;

        print(
            '🛒 CartScreen: Processing transaction $transactionId with ${items.length} items');
        print('🛒 CartScreen: First item: $firstItem');

        // Calculate total amount
        final totalAmount = items.fold<double>(
            0.0, (sum, item) => sum + (item['totalPrice'] ?? 0.0));

        print('🛒 CartScreen: Calculated total amount: $totalAmount');

        final invoice = {
          'transactionId': transactionId,
          'transactionNumber': firstItem['transactionNumber'],
          'invoiceNumber': firstItem['transactionNumber'],
          'pharmacyName': 'ABC Pharmacy',
          'pharmacyId': firstItem['transactionId'],
          'date': firstItem['createdAt'] != null
              ? DateTime.parse(firstItem['createdAt'])
                  .toIso8601String()
                  .split('T')[0]
              : DateTime.now().toIso8601String().split('T')[0],
          'invoiceType': 'complete',
          'totalAmount': totalAmount,
          'discount': 0.0,
          'finalAmount': totalAmount,
          'medicines': items.map((item) {
            print('🛒 CartScreen: Processing medicine item: $item');
            return {
              'id': item['medicineId']['_id'] ?? item['medicineId']['id'],
              'name': item['medicineName'] ?? item['medicineId']['name'],
              'genericName':
                  item['genericName'] ?? item['medicineId']['genericName'],
              'activeIngredient':
                  item['genericName'] ?? item['medicineId']['genericName'],
              'category': 'Medicine',
              'manufacturer': item['manufacturer'] ?? 'Unknown',
              'price': item['unitPrice'] ?? item['medicineId']['price'] ?? 0.0,
              'quantity': item['quantity'] ?? 1,
              'form': item['form'] ?? item['medicineId']['form'] ?? 'Tablet'
            };
          }).toList(),
          'status': 'completed',
          'createdAt': firstItem['createdAt']
        };

        print('🛒 CartScreen: Created invoice: $invoice');
        return invoice;
      }).toList();

      print('🛒 CartScreen: Converted to ${invoiceItems.length} invoices');
      for (int i = 0; i < invoiceItems.length; i++) {
        print('🛒 CartScreen: Invoice $i: ${invoiceItems[i]}');
      }

      print('🛒 CartScreen: Final invoice items: ${invoiceItems.length}');
      for (int i = 0; i < invoiceItems.length; i++) {
        final item = invoiceItems[i];
        print(
            '🛒 CartScreen: Invoice $i: totalAmount=${item['totalAmount']}, finalAmount=${item['finalAmount']}');
      }

      setState(() {
        _cartItems = invoiceItems;
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
            content: Text(
                '${AppLocalizations.of(context)!.failedToLoadCart}: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.retry,
              textColor: Colors.white,
              onPressed: _loadCartItems,
            ),
          ),
        );
      }
    }
  }

  double get _subtotal {
    print('🛒 CartScreen: Calculating subtotal for ${_cartItems.length} items');
    double total = 0.0;
    for (int i = 0; i < _cartItems.length; i++) {
      final item = _cartItems[i];
      final totalAmount = item['totalAmount'] ?? item['finalAmount'] ?? 0.0;
      print('🛒 CartScreen: Item $i: totalAmount=$totalAmount');
      total += totalAmount;
    }
    print('🛒 CartScreen: Final subtotal: $total');
    return total;
  }

  double get _tax => _subtotal * 0.05; // 5% tax
  double get _total => _subtotal + _tax;

  Future<void> _updateQuantity(String itemId, int newQuantity) async {
    try {
      if (newQuantity <= 0) {
        await _removeItem(itemId);
        return;
      }

      await _apiService.updateCartItem(itemId, {'quantity': newQuantity});

      setState(() {
        final itemIndex = _cartItems.indexWhere((item) => item['id'] == itemId);
        if (itemIndex != -1) {
          _cartItems[itemIndex]['quantity'] = newQuantity;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.failedToUpdateQuantity}: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _removeItem(String itemId) async {
    try {
      await _apiService.removeFromCart(itemId);

      setState(() {
        _cartItems.removeWhere((item) => item['id'] == itemId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.itemRemovedFromCart),
            backgroundColor: AppTheme.successGreen,
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.undo,
              textColor: Colors.white,
              onPressed: () {
                // TODO: Implement undo functionality
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.failedToRemoveItem}: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _clearCart() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.clearAll,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.errorRed,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: Text(
              AppLocalizations.of(context)!.clearAll,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      print('🗑️ Cart: Clearing all cart items...');

      // Get all cart items first
      final allItems = await _apiService.getCartItems();
      print('🗑️ Cart: Found ${allItems.length} items to process');

      // Group items by transaction to get unique transaction IDs
      final Set<String> transactionIds = {};
      for (var item in allItems) {
        final transactionId =
            item['transactionId'] ?? item['transactionNumber'];
        if (transactionId != null) {
          transactionIds.add(transactionId.toString());
        }
      }

      print(
          '🗑️ Cart: Found ${transactionIds.length} unique transactions to remove');

      // Remove each transaction individually to ensure they are permanently deleted
      for (var transactionId in transactionIds) {
        print('🗑️ Cart: Removing transaction with ID: $transactionId');
        await _apiService.removeFromCart(transactionId);
      }

      print('🗑️ Cart: All transactions removed successfully');

      // Update UI by reloading cart items
      await _loadCartItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.cartClearedSuccessfully),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Cart: Failed to clear cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear cart: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _proceedToCheckout() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.yourCartIsEmpty),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    AppRoutes.navigateTo(context, AppRoutes.checkout);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.shoppingCart,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_cartItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: _clearCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.clear_all, size: 18),
                label: Text(
                  AppLocalizations.of(context)!.clearAll,
                  style: const TextStyle(fontSize: 14),
                ),
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
                        child: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                )
              : _cartItems.isEmpty
                  ? _buildEmptyCart(theme)
                  : Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _loadCartItems,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _cartItems.length,
                              itemBuilder: (context, index) {
                                return _buildCartItem(_cartItems[index], theme);
                              },
                            ),
                          ),
                        ),
                        _buildOrderSummary(theme),
                      ],
                    ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, ThemeData theme) {
    // Only show invoices now
    return _buildInvoiceCartItem(item, theme);
  }

  Widget _buildMedicineCartItem(Map<String, dynamic> item, ThemeData theme) {
    print('🛒 Building medicine cart item: $item');

    final bool hasDiscount = (item['discount'] ?? 0) > 0;
    final bool isPrescriptionRequired = !(item['isOTC'] ?? true);
    final double unitPrice = item['unitPrice'] ?? item['price'] ?? 0.0;
    final int quantity = item['quantity'] ?? 1;
    final double itemTotal = unitPrice * quantity;

    print(
        '🛒 Medicine details: unitPrice=$unitPrice, quantity=$quantity, total=$itemTotal');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image & Icons
              Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: AppTheme.primaryTeal.withOpacity(0.1),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: item['imageUrl'] != null
                          ? Image.network(
                              item['imageUrl'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppTheme.primaryTeal.withOpacity(0.1),
                                  child: Icon(
                                    _getFormIcon(item['form'] ?? 'Tablet'),
                                    color: AppTheme.primaryTeal,
                                    size: 32,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: AppTheme.primaryTeal.withOpacity(0.1),
                              child: Icon(
                                _getFormIcon(item['form'] ?? 'Tablet'),
                                color: AppTheme.primaryTeal,
                                size: 32,
                              ),
                            ),
                    ),
                  ),
                  if (isPrescriptionRequired)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Rx',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (hasDiscount)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${item['discount']}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Medicine Name
                    Text(
                      item['medicineName'] ??
                          item['name'] ??
                          'Unknown Medicine',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Generic Name & Form
                    Text(
                      '${item['genericName'] ?? AppLocalizations.of(context)!.unknown} • ${item['form'] ?? 'Tablet'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Manufacturer & Pack Size
                    Text(
                      '${item['manufacturer'] ?? AppLocalizations.of(context)!.unknown} • ${item['packSize'] ?? '1 unit'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Price
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '\$${unitPrice.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '\$${(item['originalPrice'] ?? item['price'] ?? 0.0).toStringAsFixed(2)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryTeal.withOpacity(0.1),
                                AppTheme.primaryTeal.withOpacity(0.05)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${AppLocalizations.of(context)!.total}: \$${itemTotal.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Remove Button
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () => _removeItem(item['id'] ?? ''),
                  icon: const Icon(Icons.close),
                  iconSize: 18,
                  color: AppTheme.errorRed,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Quantity Controls & Additional Info
          Row(
            children: [
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: AppTheme.primaryTeal.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                  color: AppTheme.primaryTeal.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _updateQuantity(
                            item['id'] ?? '', (item['quantity'] ?? 1) - 1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.remove,
                            size: 18,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '${item['quantity'] ?? 1}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _updateQuantity(
                            item['id'] ?? '', (item['quantity'] ?? 1) + 1),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.add,
                            size: 18,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Expiry Date
              if (item['expiryDate'] != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.1),
                        Colors.orange.withOpacity(0.05)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${AppLocalizations.of(context)!.exp}: ${item['expiryDate'].toString().substring(0, 10)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
      default:
        return Icons.medication;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pain Relief':
        return Icons.healing;
      case 'Antibiotics':
        return Icons.biotech;
      case 'Vitamins':
        return Icons.local_pharmacy;
      case 'Cold & Flu':
        return Icons.air;
      case 'Heart':
        return Icons.favorite;
      case 'Diabetes':
        return Icons.water_drop;
      default:
        return Icons.medication;
    }
  }

  Widget _buildInvoiceCartItem(Map<String, dynamic> item, ThemeData theme) {
    print('🛒 CartScreen: Building invoice cart item: $item');

    // Extract data from the item structure
    final String invoiceNumber =
        item['invoiceNumber'] ?? item['transactionNumber'] ?? 'INV-000';
    final String pharmacyName = item['pharmacyName'] ?? 'Pharmacy';
    final String invoiceDate = item['date'] ??
        (item['createdAt'] != null
            ? DateTime.parse(item['createdAt'])
                .toLocal()
                .toString()
                .split(' ')[0]
            : '');
    final String invoiceType = item['invoiceType'] ?? 'Complete';
    final int medicineCount = (item['medicines'] as List?)?.length ?? 1;
    final double totalAmount = (item['totalAmount'] ?? 0.0) as double;
    final double discount = (item['discount'] ?? 0.0) as double;
    final double finalAmount = (item['finalAmount'] ?? totalAmount) as double;

    print(
        '🛒 CartScreen: Extracted data - invoiceNumber: $invoiceNumber, pharmacyName: $pharmacyName, invoiceDate: $invoiceDate, invoiceType: $invoiceType, medicineCount: $medicineCount, totalAmount: $totalAmount');

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
                      invoiceNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                    Text(
                      pharmacyName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _removeInvoiceFromCart(item),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppTheme.errorRed,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
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
                      'Invoice Date',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      invoiceDate,
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
                      'Invoice Type',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      invoiceType,
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
                      'Medicines',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '$medicineCount Item',
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
                        'Discount',
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${finalAmount.toStringAsFixed(2)} EGP',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Medicines List (Collapsible)
          ExpansionTile(
            title: Text(
              'Medicines in Invoice',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.primaryTeal,
              ),
            ),
            children: [
              // Show all medicines in the invoice
              ...((item['medicines'] as List?) ?? []).map<Widget>((medicine) {
                print('🛒 CartScreen: Displaying medicine: $medicine');
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
                        _getCategoryIcon(medicine['form'] ?? 'Tablet'),
                        color: AppTheme.primaryTeal,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medicine['name'] ?? 'N/A',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              medicine['manufacturer'] ?? 'N/A',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                            if (medicine['quantity'] != null &&
                                (medicine['quantity'] as int) > 1)
                              Text(
                                'Qty: ${medicine['quantity']}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[500],
                                  fontSize: 9,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '${medicine['price']} EGP',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(ThemeData theme) {
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
        children: [
          // Summary Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.subtotal,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '\$${_subtotal.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.tax} (5%)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '\$${_tax.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.total,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      Text(
                        '\$${_total.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Checkout Button
          Container(
            width: double.infinity,
            height: 56,
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
              onPressed: _proceedToCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.shopping_cart_checkout, size: 22),
              label: Text(
                AppLocalizations.of(context)!.proceedToCheckout,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return Center(
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
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ) ??
                const TextStyle(),
            child: Text(
              AppLocalizations.of(context)!.yourCartIsEmpty,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 400),
            style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ) ??
                const TextStyle(),
            child: Text(
              AppLocalizations.of(context)!.addSomeMedicinesToGetStarted,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
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
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.store, size: 24, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)!.browseMedicines,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInvoiceDetails(Map<String, dynamic> invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Invoice details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Invoice header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryTeal.withOpacity(0.1),
                            AppTheme.primaryTeal.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryTeal.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.receipt_long,
                                color: AppTheme.primaryTeal,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  invoice['invoiceNumber'] ?? 'Invoice',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            AppLocalizations.of(context)!.pharmacyName,
                            invoice['pharmacyName'] ?? '',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            AppLocalizations.of(context)!.pharmacyAddress,
                            invoice['pharmacyAddress'] ?? '',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            AppLocalizations.of(context)!.pharmacyPhone,
                            invoice['pharmacyPhone'] ?? '',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            AppLocalizations.of(context)!.invoiceDate,
                            invoice['date'] ?? '',
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            AppLocalizations.of(context)!.invoiceType,
                            invoice['invoiceType'] == 'complete'
                                ? AppLocalizations.of(context)!.completeInvoice
                                : AppLocalizations.of(context)!.partialInvoice,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            AppLocalizations.of(context)!.totalAmount,
                            '\$${invoice['totalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                          ),
                          if (invoice['discount'] > 0) ...[
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              AppLocalizations.of(context)!.discount,
                              '${invoice['discount']}%',
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              AppLocalizations.of(context)!.finalAmount,
                              '\$${invoice['finalAmount']?.toStringAsFixed(2) ?? '0.00'}',
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Medicines list
                    Text(
                      AppLocalizations.of(context)!.medicinesInInvoice,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Medicines
                    ...invoice['medicines']?.map<Widget>((medicine) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _getFormIcon(
                                          medicine['form'] ?? 'Tablet'),
                                      color: AppTheme.primaryTeal,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        medicine['name'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '\$${medicine['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.successGreen,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '${AppLocalizations.of(context)!.quantity}: ${medicine['quantity'] ?? 1}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '${AppLocalizations.of(context)!.price}: \$${medicine['price']?.toStringAsFixed(2) ?? '0.00'}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  medicine['manufacturer'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList() ??
                        [],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _removeFromCart(String itemId) async {
    try {
      await _apiService.removeFromCart(itemId);
      await _loadCartItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.itemRemovedFromCart),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove item: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _removeInvoiceFromCart(Map<String, dynamic> invoice) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Remove Invoice',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.errorRed,
          ),
        ),
        content: Text(
          'Are you sure you want to remove this invoice from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final String? transactionId = invoice['transactionId'];
      if (transactionId == null) {
        throw Exception('Transaction ID not found');
      }

      print('🗑️ Cart: Removing invoice with transaction ID: $transactionId');

      // Get all cart items for this transaction
      final allItems = await _apiService.getCartItems();
      final itemsToRemove = allItems.where((item) {
        final itemTransactionId =
            item['transactionId'] ?? item['transactionNumber'];
        return itemTransactionId == transactionId;
      }).toList();

      print('🗑️ Cart: Found ${itemsToRemove.length} items to remove');

      // Remove the transaction directly using transaction ID
      print('🗑️ Cart: Removing transaction with ID: $transactionId');
      await _apiService.removeFromCart(transactionId);

      // Reload cart items to refresh the UI
      await _loadCartItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.itemRemovedFromCart),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Cart: Failed to remove invoice: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove invoice: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
