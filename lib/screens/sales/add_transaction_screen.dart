import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ApiService _apiService = ApiService();

  String? _selectedTransactionType;
  final List<Map<String, dynamic>> _transactionItems = [];
  List<Map<String, dynamic>> _availableMedicines = [];
  bool _isProcessing = false;

  List<String> get _transactionTypes => [
        AppLocalizations.of(context)!.fullReceipt,
        AppLocalizations.of(context)!.perMedicine,
      ];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    try {
      await _apiService.initialize();

      // Load medicines from API
      final medicines = await _apiService.getMedicines();

      setState(() {
        _availableMedicines = medicines;
      });
    } catch (e) {
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load medicines: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.retry,
              textColor: Colors.white,
              onPressed: _loadMedicines,
            ),
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredMedicines {
    if (_searchController.text.isEmpty) return _availableMedicines;

    return _availableMedicines
        .where((medicine) =>
            medicine['name']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            medicine['genericName']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
        .toList();
  }

  double get _subtotal => _transactionItems.fold(
      0, (sum, item) => sum + (item['price'] * item['quantity']));
  double get _tax => _subtotal * 0.05; // 5% tax
  double get _total => _subtotal + _tax;

  @override
  void dispose() {
    _searchController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addMedicineToTransaction(Map<String, dynamic> medicine) {
    showDialog(
      context: context,
      builder: (context) => _MedicineSelectionDialog(
        medicine: medicine,
        onAdd: (quantity, price, expiryDate) {
          setState(() {
            final existingIndex = _transactionItems
                .indexWhere((item) => item['medicineId'] == medicine['id']);

            if (existingIndex != -1) {
              _transactionItems[existingIndex]['quantity'] += quantity;
            } else {
              _transactionItems.add({
                'medicineId': medicine['id'],
                'name': medicine['name'],
                'genericName': medicine['genericName'],
                'form': medicine['form'],
                'packSize': medicine['packSize'],
                'manufacturer': medicine['manufacturer'],
                'batchNumber': medicine['batchNumber'],
                'quantity': quantity,
                'price': price,
                'expiryDate': expiryDate,
                'lineTotal': price * quantity,
              });
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${medicine['name']} added to transaction'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        },
      ),
    );
  }

  void _removeItemFromTransaction(int index) {
    setState(() {
      _transactionItems.removeAt(index);
    });
  }

  void _updateItemQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      _removeItemFromTransaction(index);
      return;
    }

    setState(() {
      _transactionItems[index]['quantity'] = newQuantity;
      _transactionItems[index]['lineTotal'] =
          _transactionItems[index]['price'] * newQuantity;
    });
  }

  Future<void> _processTransaction() async {
    if (_transactionItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context)!.pleaseAddAtLeastOneMedicine),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      await _apiService.initialize();

      final transactionRef = _generateTransactionReference();

      // Prepare transaction data for API
      final transactionData = {
        'transactionType': _selectedTransactionType?.toLowerCase() ?? 'sale',
        'description': _descriptionController.text.trim(),
        'items': _transactionItems
            .map((item) => {
                  'medicineId': item['medicineId'],
                  'quantity': item['quantity'],
                  'unitPrice': item['price'],
                })
            .toList(),
        'customerName': 'Walk-in Customer', // Default customer
        'customerPhone': '', // Optional
        'paymentMethod': 'cash', // Default for now
        'tax': _tax,
        'discount': 0.0,
        'status': 'completed',
      };

      // Send transaction to API
      final response = await _apiService.processCheckout(transactionData);
      final transactionId =
          response['data']?['transactionId'] ?? transactionRef;

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(
              Icons.check_circle,
              color: AppTheme.successGreen,
              size: 64,
            ),
            title: Text(AppLocalizations.of(context)!.transactionCompleted),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    '${AppLocalizations.of(context)!.transactionReference}: $transactionId'),
                const SizedBox(height: 8),
                Text(
                    '${AppLocalizations.of(context)!.type}: $_selectedTransactionType'),
                const SizedBox(height: 8),
                Text(
                    '${AppLocalizations.of(context)!.totalAmount}: \$${_total.toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                Text(
                    '${AppLocalizations.of(context)!.items}: ${_transactionItems.length}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true); // Return true to refresh
                },
                child: Text(AppLocalizations.of(context)!.done),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resetTransaction();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: Colors.white,
                ),
                child: Text(AppLocalizations.of(context)!.addAnother),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _resetTransaction() {
    _formKey.currentState?.reset();
    _descriptionController.clear();
    setState(() {
      _selectedTransactionType = null;
      _transactionItems.clear();
    });
  }

  String _generateTransactionReference() {
    final now = DateTime.now();
    return 'TX-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.newSale,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _resetTransaction,
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.resetTransaction,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppTheme.primaryTeal.withOpacity(0.1),
              child: Column(
                children: [
                  const Icon(
                    Icons.point_of_sale,
                    size: 48,
                    color: AppTheme.primaryTeal,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.processNewSale,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.addMedicinesProcess,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkGray.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction Type & Customer Info
                    _buildTransactionHeader(),
                    const SizedBox(height: 24),

                    // Medicine Search & Selection
                    _buildMedicineSelection(),
                    const SizedBox(height: 24),

                    // Transaction Items
                    if (_transactionItems.isNotEmpty) ...[
                      _buildTransactionItems(),
                      const SizedBox(height: 24),
                    ],

                    // Transaction Summary
                    if (_transactionItems.isNotEmpty)
                      _buildTransactionSummary(),
                  ],
                ),
              ),
            ),

            // Bottom Action
            if (_transactionItems.isNotEmpty) _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.transactionDetails,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Transaction Type
          DropdownButtonFormField<String>(
            value: _selectedTransactionType,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.transactionType,
              prefixIcon:
                  const Icon(Icons.receipt_long, color: AppTheme.primaryTeal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _transactionTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTransactionType = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          // Description (Optional)
          TextFormField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.descriptionOptional,
              hintText: AppLocalizations.of(context)!.addTransactionNotes,
              prefixIcon:
                  const Icon(Icons.description, color: AppTheme.primaryTeal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.addMedicineItems,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Search Field
          TextFormField(
            controller: _searchController,
            onChanged: (value) => setState(() {}),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.searchMedicines,
              hintText: AppLocalizations.of(context)!.searchByCommercialName,
              prefixIcon: const Icon(Icons.search, color: AppTheme.primaryTeal),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Available Medicines List
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: _filteredMedicines.length,
              itemBuilder: (context, index) {
                final medicine = _filteredMedicines[index];
                return _buildMedicineListItem(medicine);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineListItem(Map<String, dynamic> medicine) {
    final bool isLowStock = medicine['stock'] < 10;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getFormIcon(medicine['form']),
            color: AppTheme.primaryTeal,
          ),
        ),
        title: Text(
          medicine['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${medicine['genericName']} • ${medicine['manufacturer']}'),
            Text(
                '${AppLocalizations.of(context)!.stock}: ${medicine['stock']} • \$${medicine['price'].toStringAsFixed(2)}'),
            if (isLowStock)
              Text(
                AppLocalizations.of(context)!.lowStock,
                style: TextStyle(
                  color: AppTheme.errorRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: medicine['stock'] > 0
              ? () => _addMedicineToTransaction(medicine)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryTeal,
            foregroundColor: Colors.white,
            minimumSize: const Size(60, 36),
          ),
          child: Text(medicine['stock'] > 0
              ? AppLocalizations.of(context)!.add
              : AppLocalizations.of(context)!.out),
        ),
      ),
    );
  }

  Widget _buildTransactionItems() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.transactionItems,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '${_transactionItems.length} ${AppLocalizations.of(context)!.items}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...(_transactionItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildTransactionItem(item, index);
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${item['genericName']} • ${item['form']}'),
                Text('${item['manufacturer']} • ${item['packSize']}'),
                Text(
                    '${AppLocalizations.of(context)!.batch}: ${item['batchNumber']} • ${AppLocalizations.of(context)!.exp}: ${item['expiryDate'].substring(0, 10)}'),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () =>
                        _updateItemQuantity(index, item['quantity'] - 1),
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 20,
                    color: AppTheme.primaryTeal,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('${item['quantity']}'),
                  ),
                  IconButton(
                    onPressed: () =>
                        _updateItemQuantity(index, item['quantity'] + 1),
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 20,
                    color: AppTheme.primaryTeal,
                  ),
                ],
              ),
              Text(
                '\$${item['lineTotal'].toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _removeItemFromTransaction(index),
            icon: const Icon(Icons.delete_outline),
            color: AppTheme.errorRed,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.subtotal),
              Text('\$${_subtotal.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.tax5),
              Text('\$${_tax.toStringAsFixed(2)}'),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.total,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '\$${_total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _resetTransaction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                side: const BorderSide(color: AppTheme.primaryTeal),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(AppLocalizations.of(context)!.reset),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.processTransaction,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
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
}

class _MedicineSelectionDialog extends StatefulWidget {
  final Map<String, dynamic> medicine;
  final Function(int quantity, double price, String expiryDate) onAdd;

  const _MedicineSelectionDialog({
    required this.medicine,
    required this.onAdd,
  });

  @override
  State<_MedicineSelectionDialog> createState() =>
      _MedicineSelectionDialogState();
}

class _MedicineSelectionDialogState extends State<_MedicineSelectionDialog> {
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  String _selectedExpiryDate = '';

  @override
  void initState() {
    super.initState();
    _priceController.text = widget.medicine['price'].toString();
    _selectedExpiryDate = widget.medicine['expiryDate'];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.add),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.quantity,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.pricePerUnit,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.expiryDate),
          Text(AppLocalizations.of(context)!.stockAvailable),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final quantity = int.tryParse(_quantityController.text) ?? 1;
            final price = double.tryParse(_priceController.text) ??
                widget.medicine['price'];

            if (quantity > 0 && quantity <= widget.medicine['stock']) {
              widget.onAdd(quantity, price, _selectedExpiryDate);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!
                      .invalidQuantityInsufficientStock),
                  backgroundColor: AppTheme.errorRed,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryTeal,
            foregroundColor: Colors.white,
          ),
          child: Text(AppLocalizations.of(context)!.addToTransaction),
        ),
      ],
    );
  }
}
