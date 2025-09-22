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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCategories();
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

      // Use API to get market medicines
      final response = await _apiService.searchMarketMedicines();
      final medicinesData = response['data'] ?? response;
      final medicines =
          List<Map<String, dynamic>>.from(medicinesData['medicines'] ?? []);

      setState(() {
        _medicines = medicines;
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
      setState(() {
        _cartItemCount = cartItems.length;
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
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
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
    final int medicineCount = invoice['medicines']?.length ?? 0;

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
                                ? AppLocalizations.of(context)!.completeInvoice
                                : AppLocalizations.of(context)!.partialInvoice,
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
                    ...invoice['medicines'].take(3).map<Widget>((medicine) {
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
                                    medicine['name'] ?? 'N/A',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 10,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    medicine['manufacturer'] ?? 'N/A',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                      fontSize: 8,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    medicine['activeIngredient'] ?? 'N/A',
                                    style: theme.textTheme.bodySmall?.copyWith(
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
                              '${medicine['price']} EGP',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppTheme.successGreen,
                                fontSize: 9,
                              ),
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
                                  color: AppTheme.primaryTeal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Icon(
                                  _getCategoryIcon(medicine['category'] ?? ''),
                                  size: 12,
                                  color: AppTheme.primaryTeal,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      medicine['activeIngredient'] ?? 'Unknown',
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
                        ? AppTheme.errorRed
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
      // Add each medicine from the invoice to cart
      for (var medicine in invoice['medicines'] ?? []) {
        await _apiService.addToCart({
          'medicineId': medicine['id'],
          'quantity': medicine['quantity'] ?? 1,
          'price': medicine['price'],
        });
      }
      await _updateCartCount();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to cart'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: ${e.toString()}'),
            backgroundColor: Colors.red,
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
