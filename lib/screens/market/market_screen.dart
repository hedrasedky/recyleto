import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../utils/app_routes.dart';
import '../../utils/app_theme.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  String _selectedCategory = 'All'; // Will be updated in initState
  String _searchQuery = '';
  int _cartItemCount = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<String> _categories = [];

  List<Map<String, dynamic>> _medicines = [];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    _updateCartCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCategories();
    _updateCartCount();
    // Refresh medicines when returning to market screen
    _loadMedicines();
  }

  void _updateCategories() {
    _categories = [
      AppLocalizations.of(context)!.allCategories,
      AppLocalizations.of(context)!.painRelief,
      AppLocalizations.of(context)!.antibiotics,
      AppLocalizations.of(context)!.vitamins,
      AppLocalizations.of(context)!.coldFlu,
      AppLocalizations.of(context)!.heart,
      AppLocalizations.of(context)!.diabetes,
      AppLocalizations.of(context)!.gastrointestinal,
      AppLocalizations.of(context)!.allergy
    ];

    // Set selected category to first category if not already set
    if (_selectedCategory == 'All') {
      _selectedCategory = _categories.first;
    }
  }

  Future<void> _loadMedicines() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Use API to get transactions (not medicines)
      final transactions = await _apiService.getTransactions();

      print('💊 Market: Raw transactions: $transactions');
      print('💊 Market: Transactions count: ${transactions.length}');

      // Log each transaction details
      for (int i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];
        final items = transaction['items'] as List? ?? [];
        print(
            '💊 Market: Transaction $i: ID=${transaction['_id']}, Items=${items.length}, Status=${transaction['status']}, TransactionType=${transaction['transactionType']}');
      }

      // Filter transactions to only show complete invoices (with multiple medicines)
      // Skip single-item transactions as they are not complete invoices
      // Also skip transactions that are already in cart (status: pending)
      final completeInvoices = transactions.where((transaction) {
        // Only show transactions that have multiple items or are marked as complete invoices
        final items = transaction['items'] as List? ?? [];
        final hasMultipleItems = items.length > 1;
        final isNotInCart = transaction['status'] != 'pending';
        final isSaleTransaction = transaction['transactionType'] == 'sale' ||
            transaction['transactionType'] == null;
        final isCompletedTransaction = transaction['status'] == 'completed';

        print(
            '💊 Market: Transaction ${transaction['_id']}: ${items.length} items, hasMultipleItems: $hasMultipleItems, isNotInCart: $isNotInCart, isSaleTransaction: $isSaleTransaction, isCompletedTransaction: $isCompletedTransaction');

        // Show completed sale transactions with multiple items that are not in cart

        return hasMultipleItems && isNotInCart;
      }).toList();

      print('💊 Market: Complete invoices found: ${completeInvoices.length}');

      // Remove duplicate transactions based on transactionId
      final uniqueInvoices = <String, Map<String, dynamic>>{};
      for (var transaction in completeInvoices) {
        final transactionId = transaction['_id'] ??
            transaction['transactionId'] ??
            transaction['id'];
        print('💊 Market: Processing transaction ID: $transactionId');
        if (transactionId != null &&
            !uniqueInvoices.containsKey(transactionId)) {
          uniqueInvoices[transactionId] = transaction;
          print('💊 Market: Added unique transaction: $transactionId');
        } else {
          print('💊 Market: Skipped duplicate transaction: $transactionId');
        }
      }

      print(
          '💊 Market: Unique invoices after deduplication: ${uniqueInvoices.length}');

      // Convert unique transactions to invoice format for display
      final invoices = uniqueInvoices.values.map((transaction) {
        return {
          'invoiceNumber': transaction['transactionId'] ??
              transaction['transactionReference'] ??
              transaction['id'] ??
              'Unknown',
          'pharmacyName': 'ABC Pharmacy', // Default pharmacy name
          'pharmacyId': transaction['pharmacyId'] ?? 'pharmacy_123',
          'date': transaction['createdAt'] != null
              ? DateTime.parse(transaction['createdAt'])
                  .toIso8601String()
                  .split('T')[0]
              : DateTime.now().toIso8601String().split('T')[0],
          'invoiceType': 'complete', // Default to complete
          'totalAmount': transaction['totalAmount'] ??
              transaction['total'] ??
              transaction['amount'] ??
              0.0,
          'discount': 0.0, // Default discount
          'finalAmount': transaction['totalAmount'] ??
              transaction['total'] ??
              transaction['amount'] ??
              0.0,
          'medicines': transaction['items']
                  ?.map((item) => {
                        'id': item['medicineId'],
                        'name': item['medicineName'] ??
                            item['name'] ??
                            'Unknown Medicine',
                        'genericName': item['genericName'] ?? 'Unknown',
                        'activeIngredient': item['genericName'] ?? 'Unknown',
                        'category': 'Medicine',
                        'manufacturer': item['manufacturer'] ?? 'Unknown',
                        'price': item['unitPrice'] ?? item['price'] ?? 0.0,
                        'quantity': item['quantity'] ?? 1,
                        'form': item['form'] ?? 'Tablet'
                      })
                  .toList() ??
              [],
          'status': transaction['status'] ?? 'completed',
          'createdAt':
              transaction['createdAt'] ?? DateTime.now().toIso8601String()
        };
      }).toList();

      print('💊 Market: Converted invoices: ${invoices.length}');

      // Only show real invoices from backend, no sample data
      setState(() {
        _medicines = invoices; // Store as invoices for display
        _isLoading = false;
      });

      // Update cart count
      await _updateCartCount();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load medicines: ${e.toString()}';
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load medicines: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadMedicines,
            ),
          ),
        );
      }
    }
  }

  Future<void> _searchMedicines(String query) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Use API to search market medicines
      final response = await _apiService.searchMarketMedicines(query: query);
      final medicinesData = response['data'] ?? response;
      final medicines =
          List<Map<String, dynamic>>.from(medicinesData['medicines'] ?? []);

      setState(() {
        _medicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to search medicines: ${e.toString()}';
      });

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to search medicines: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _searchMedicines(query),
            ),
          ),
        );
      }
    }
  }

  Future<void> _updateCartCount() async {
    try {
      final cartItems = await _apiService.getCartItems();

      // Count unique transactions (invoices) in cart
      final Set<String> uniqueTransactions = {};
      for (var item in cartItems) {
        final transactionId =
            item['transactionId'] ?? item['transactionNumber'] ?? 'unknown';
        uniqueTransactions.add(transactionId);
      }

      setState(() {
        _cartItemCount = uniqueTransactions.length;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  List<Map<String, dynamic>> get _filteredMedicines {
    return _medicines.where((invoice) {
      // Filter by category
      bool categoryMatch = _selectedCategory == _categories.first ||
          invoice['medicines']
              .any((medicine) => medicine['category'] == _selectedCategory);

      // Filter by search query
      bool searchMatch = _searchQuery.isEmpty ||
          invoice['pharmacyName']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          invoice['medicines'].any((medicine) =>
              medicine['name']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              medicine['manufacturer']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()));

      return categoryMatch && searchMatch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.market),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        actions: [
          // Cart icon with count
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.cart);
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.errorRed,
                          AppTheme.errorRed.withOpacity(0.8)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.errorRed.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$_cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          // Notifications icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/notifications');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.scaffoldBackgroundColor,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchMedicinesHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              _loadMedicines();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    if (value.isEmpty) {
                      _loadMedicines();
                    } else {
                      _searchMedicines(value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: AppTheme.primaryTeal.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryTeal,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMedicines,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    if (_filteredMedicines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noMedicinesFound,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.tryAdjustingSearch,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = _categories.first;
                });
                _loadMedicines();
              },
              child: Text(AppLocalizations.of(context)!.clearFilters),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredMedicines.length,
      itemBuilder: (context, index) {
        final invoice = _filteredMedicines[index];
        return _buildInvoiceCard(invoice);
      },
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    final theme = Theme.of(context);
    final double totalAmount = invoice['totalAmount'] ?? 0.0;
    final double discount = invoice['discount'] ?? 0.0;
    final double finalAmount = invoice['finalAmount'] ?? totalAmount;
    // Calculate total medicine count (including duplicates)
    final int medicineCount = (invoice['medicines'] as List? ?? []).fold<int>(
        0, (sum, medicine) => sum + ((medicine['quantity'] ?? 1) as int));

    return StatefulBuilder(
      builder: (context, setState) {
        bool isExpanded = false;

        return Container(
          padding: const EdgeInsets.all(8),
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Invoice Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: AppTheme.primaryTeal,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invoice['invoiceNumber'] ?? 'Invoice',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryTeal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            invoice['pharmacyName'] ?? 'Pharmacy',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${finalAmount.toStringAsFixed(2)} EGP',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successGreen,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Invoice Details
                Container(
                  padding: const EdgeInsets.all(6),
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
                            'Date',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              invoice['date'] ?? '',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Type',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          Flexible(
                            child: Text(
                              invoice['invoiceType'] == 'complete'
                                  ? AppLocalizations.of(context)!
                                      .completeInvoice
                                  : AppLocalizations.of(context)!
                                      .partialInvoice,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Items',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '$medicineCount',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (discount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${discount}%',
                              style: theme.textTheme.bodySmall?.copyWith(
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
                const SizedBox(height: 6),

                // Medicines Preview (First 3 medicines)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medicines Preview',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 3),
                      ...(invoice['medicines'] as List? ?? [])
                          .take(3)
                          .map<Widget>((medicine) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 3),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getCategoryIcon(
                                    medicine['category'] ?? 'Tablet'),
                                color: AppTheme.primaryTeal,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      medicine['name'] ??
                                          medicine['medicineName'] ??
                                          'Unknown Medicine',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      medicine['manufacturer'] ?? 'N/A',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[600],
                                        fontSize: 8,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      medicine['activeIngredient'] ?? 'N/A',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[500],
                                        fontSize: 7,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${medicine['price']} EGP',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.successGreen,
                                      fontSize: 9,
                                    ),
                                  ),
                                  if ((medicine['quantity'] ?? 1) > 1)
                                    Text(
                                      '×${medicine['quantity']}',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryTeal,
                                        fontSize: 8,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      if (medicineCount > 3) ...[
                        const SizedBox(height: 3),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 3, horizontal: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: AppTheme.primaryTeal.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'View More (${medicineCount - 3} more)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.primaryTeal,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: AppTheme.primaryTeal,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Additional medicines when expanded
                if (isExpanded && medicineCount > 3) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Medicines',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 3),
                        ...invoice['medicines'].skip(3).map<Widget>((medicine) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 3),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color:
                                        AppTheme.primaryTeal.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(
                                        medicine['category'] ?? ''),
                                    size: 12,
                                    color: AppTheme.primaryTeal,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medicine['name'] ?? 'Unknown Medicine',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 9,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        medicine['manufacturer'] ?? 'Unknown',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                          fontSize: 8,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        medicine['activeIngredient'] ??
                                            'Unknown',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[500],
                                          fontSize: 7,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${medicine['price']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.successGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleInvoiceAction(invoice),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: invoice['invoiceType'] == 'complete'
                          ? AppTheme.primaryTeal
                          : AppTheme.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      invoice['invoiceType'] == 'complete'
                          ? AppLocalizations.of(context)!.addCompleteInvoice
                          : AppLocalizations.of(context)!.selectPartialInvoice,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleInvoiceAction(Map<String, dynamic> invoice) {
    if (invoice['invoiceType'] == 'complete') {
      // Add complete invoice to cart
      _addInvoiceToCart(invoice);
    } else {
      // Show partial selection dialog
      _showPartialSelectionDialog(invoice);
    }
  }

  void _showPartialSelectionDialog(Map<String, dynamic> invoice) {
    showDialog(
      context: context,
      builder: (context) => _PartialSelectionDialog(
        invoice: invoice,
        onMedicinesSelected: (selectedMedicines) {
          // Create a partial invoice with selected medicines
          final partialInvoice = {
            ...invoice,
            'medicines': selectedMedicines,
            'type': 'invoice',
            'invoiceType': 'partial',
          };
          _addInvoiceToCart(partialInvoice);
        },
      ),
    );
  }

  void _addInvoiceToCart(Map<String, dynamic> invoice) async {
    try {
      // Create a single transaction with all medicines from the invoice
      final medicines = invoice['medicines'] ?? [];
      print('🔍 Market: Processing ${medicines.length} medicines from invoice');

      final items = medicines
          .map((medicine) {
            print('🔍 Market: Processing medicine: $medicine');

            // Extract the actual medicine ID (handle both string and object cases)
            String? medicineId;
            if (medicine['id'] is String) {
              medicineId = medicine['id'];
              print('🔍 Market: Found string ID: $medicineId');
            } else if (medicine['id'] is Map && medicine['id']['_id'] != null) {
              medicineId = medicine['id']['_id'];
              print('🔍 Market: Found map ID: $medicineId');
            } else if (medicine['_id'] != null) {
              medicineId = medicine['_id'];
              print('🔍 Market: Found _id: $medicineId');
            } else {
              print('❌ Market: Could not extract medicine ID from: $medicine');
              return null; // Skip this medicine if we can't get the ID
            }

            if (medicineId == null || medicineId.isEmpty) {
              print('❌ Market: Medicine ID is null or empty');
              return null;
            }

            final item = {
              'medicineId': medicineId,
              'quantity': medicine['quantity'] ?? 1,
              'unitPrice': medicine['price'] ?? 0.0,
            };

            print('🔍 Market: Created item: $item');
            return item;
          })
          .where((item) => item != null)
          .toList();

      print('🔍 Market: Adding invoice to cart with ${items.length} medicines');
      print('🔍 Market: Invoice data: $invoice');
      print('🔍 Market: Items data: $items');

      // Calculate total amount from items
      final totalAmount = items.fold<double>(0.0, (double sum, dynamic item) {
        final unitPrice = (item['unitPrice'] ?? 0.0) as double;
        final quantity = (item['quantity'] ?? 1) as int;
        return sum + (unitPrice * quantity);
      });

      print('🔍 Market: Calculated total amount: $totalAmount');

      // Create a single transaction with all medicines
      final cartData = {
        'transactionType': 'sale',
        'description': 'Complete invoice purchase',
        'items': items,
        'status': 'pending',
        'invoiceType': invoice['invoiceType'] ?? 'complete',
        'pharmacyName': invoice['pharmacyName'] ?? 'ABC Pharmacy',
        'totalAmount': totalAmount,
        'pharmacyId': invoice['pharmacyId'] ?? 'pharmacy_123',
        'date':
            invoice['date'] ?? DateTime.now().toIso8601String().split('T')[0],
      };

      print('🔍 Market: Sending cart data: $cartData');

      // Check stock availability before adding to cart
      print('🔍 Market: Checking stock availability...');
      for (var item in items) {
        final medicineId = item['medicineId'];
        final quantity = item['quantity'];
        print(
            '🔍 Market: Checking stock for medicine $medicineId, quantity $quantity');

        // Check if quantity is reasonable (not too high)
        if (quantity > 10) {
          print(
              '⚠️ Market: High quantity requested: $quantity for medicine $medicineId');
        }

        // Note: We can't check stock here without additional API call
        // The backend will handle stock validation
      }

      await _apiService.addToCart(cartData);

      await _updateCartCount();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice added to cart'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Market: Error adding invoice to cart: $e');

      // Handle specific error cases
      String errorMessage = 'Failed to add invoice to cart';
      String? medicineName;
      int? availableStock;

      if (e.toString().contains('Insufficient stock')) {
        // Extract medicine name and available stock from error message
        final match = RegExp(r'Insufficient stock for (\w+)\. Available: (\d+)')
            .firstMatch(e.toString());
        if (match != null) {
          medicineName = match.group(1);
          availableStock = int.tryParse(match.group(2) ?? '0');
          errorMessage =
              'Insufficient stock for $medicineName. Available: $availableStock';

          // Show additional info about the stock issue
          print('❌ Market: Stock issue detected:');
          print('❌ Medicine: $medicineName');
          print('❌ Available: $availableStock');
          print('❌ Requested: Unknown quantity');

          // Show detailed error message
          if (availableStock != null && availableStock > 0) {
            errorMessage =
                'Insufficient stock for $medicineName. Available: $availableStock. Please reduce quantity.';
          } else {
            errorMessage = 'Medicine $medicineName is out of stock.';
          }
        } else {
          errorMessage =
              'Insufficient stock available. Please check quantities.';
        }
      } else if (e.toString().contains('Medicine not found')) {
        errorMessage = 'Some medicines are no longer available.';
      } else if (e.toString().contains('Medicine ID is required')) {
        errorMessage = 'Invalid medicine data. Please try again.';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid request. Please check your data.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                // Retry adding the invoice
                _addInvoiceToCart(invoice);
              },
            ),
          ),
        );
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'pain relief':
        return Icons.healing;
      case 'antibiotics':
        return Icons.medication;
      case 'vitamins':
        return Icons.medication;
      case 'cold & flu':
        return Icons.sick;
      case 'heart':
        return Icons.favorite;
      case 'diabetes':
        return Icons.water_drop;
      case 'gastrointestinal':
        return Icons.restaurant;
      case 'allergy':
        return Icons.medication;
      default:
        return Icons.medication;
    }
  }
}

class _PartialSelectionDialog extends StatefulWidget {
  final Map<String, dynamic> invoice;
  final Function(List<Map<String, dynamic>>) onMedicinesSelected;

  const _PartialSelectionDialog({
    required this.invoice,
    required this.onMedicinesSelected,
  });

  @override
  State<_PartialSelectionDialog> createState() =>
      _PartialSelectionDialogState();
}

class _PartialSelectionDialogState extends State<_PartialSelectionDialog> {
  final List<Map<String, dynamic>> _selectedMedicines = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.selectMedicines),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: ListView.builder(
          itemCount: widget.invoice['medicines'].length,
          itemBuilder: (context, index) {
            final medicine = widget.invoice['medicines'][index];
            final isSelected = _selectedMedicines.contains(medicine);

            return CheckboxListTile(
              title: Text(medicine['name']),
              subtitle: Text('${medicine['price']} EGP'),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedMedicines.add(medicine);
                  } else {
                    _selectedMedicines.remove(medicine);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: _selectedMedicines.isEmpty
              ? null
              : () {
                  Navigator.pop(context);
                  widget.onMedicinesSelected(_selectedMedicines);
                },
          child: Text(AppLocalizations.of(context)!.addSelected),
        ),
      ],
    );
  }
}
