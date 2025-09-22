import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import 'add_medicine_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _medicines = [];
  bool _loadingMedicines = true;
  String? _error;
  String? _currentSearch;
  String _currentFilter = 'all'; // all | low | expiring

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _fetchMedicines();
  }

  void _checkAuthStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  Future<void> _fetchMedicines() async {
    setState(() {
      _loadingMedicines = true;
      _error = null;
    });

    try {
      List<Map<String, dynamic>> medicines = [];

      if (_currentFilter == 'low') {
        medicines = await _apiService.getLowStockMedicines();
      } else if (_currentFilter == 'expiring') {
        medicines = await _apiService.getExpiringMedicines();
      } else {
        medicines = await _apiService.getMedicines(search: _currentSearch);
      }

      setState(() {
        _medicines = medicines;
        _loadingMedicines = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingMedicines = false;
      });
    }
  }

  Future<void> _onAddMedicine() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddMedicineScreen(),
      ),
    );
    if (result == true) {
      await _fetchMedicines();
    }
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController(text: _currentSearch ?? '');
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Medicines'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Name, generic, form...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      setState(() {
        _currentSearch = value.isEmpty ? null : value;
        _currentFilter = 'all';
      });
      await _fetchMedicines();
    }
  }

  Future<void> _showFilterDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Filter'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'all'),
              child: const Text('All'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'low'),
              child: const Text('Low stock'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'expiring'),
              child: const Text('Expiring soon'),
            ),
          ],
        );
      },
    );
    if (selected != null) {
      setState(() {
        _currentFilter = selected;
        if (selected != 'all') _currentSearch = null;
      });
      await _fetchMedicines();
    }
  }

  Future<void> _showEditBottomSheet(Map<String, dynamic> med) async {
    final id = med['_id'] ?? med['id'];
    if (id == null) return;
    final quantityController = TextEditingController(
        text: (med['stock'] ?? med['quantity'] ?? '').toString());
    final priceController =
        TextEditingController(text: (med['price'] ?? '').toString());
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                med['name'] ?? 'Medicine',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.quantity,
                  prefixIcon: Icon(Icons.numbers),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.pricePerUnit,
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final qty =
                            int.tryParse(quantityController.text.trim());
                        if (qty != null) {
                          await _apiService
                              .updateMedicine(id.toString(), {'stock': qty});
                        }
                        final price =
                            double.tryParse(priceController.text.trim());
                        if (price != null) {
                          await _apiService
                              .updateMedicine(id.toString(), {'price': price});
                        }
                        if (mounted) {
                          Navigator.pop(context);
                          await _fetchMedicines();
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Medicine'),
                            content: const Text(
                                'Are you sure you want to delete this medicine?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _apiService.deleteMedicine(id.toString());
                          if (mounted) {
                            Navigator.pop(context);
                            await _fetchMedicines();
                          }
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.inventory),
        actions: [
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 80,
                    color: AppTheme.primaryTeal.withOpacity(0.5),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.inventory,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.inventory,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.darkGray.withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    onPressed: _onAddMedicine,
                    text: AppLocalizations.of(context)!.addNewMedicine,
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchMedicines,
              child: _loadingMedicines
                  ? ListView(children: const [
                      SizedBox(height: 300),
                      Center(child: CircularProgressIndicator())
                    ])
                  : _error != null
                      ? ListView(children: [
                          const SizedBox(height: 40),
                          Center(child: Text('Error: ${_error ?? ''}')),
                        ])
                      : _medicines.isEmpty
                          ? ListView(children: [
                              SizedBox(height: 80),
                              Center(
                                  child: Text(AppLocalizations.of(context)!
                                      .noMedicinesFound)),
                            ])
                          : ListView.separated(
                              itemCount: _medicines.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final med = _medicines[index];
                                final stock =
                                    med['stock'] ?? med['quantity'] ?? 0;
                                final isLowStock = stock < 10;
                                final isExpiringSoon =
                                    _isExpiringSoon(med['expiryDate']);

                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: ListTile(
                                    onTap: () => _showEditBottomSheet(med),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          _getCategoryColor(med['category']),
                                      child: Icon(
                                        _getCategoryIcon(med['category']),
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      med['name'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${med['genericName'] ?? ''} • ${med['form'] ?? ''}'),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.inventory,
                                                size: 16,
                                                color: isLowStock
                                                    ? Colors.red
                                                    : Colors.green),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Stock: $stock',
                                              style: TextStyle(
                                                color: isLowStock
                                                    ? Colors.red
                                                    : Colors.green,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(Icons.attach_money,
                                                size: 16,
                                                color: AppTheme.primaryTeal),
                                            const SizedBox(width: 4),
                                            Text(
                                              '\$${med['price']?.toStringAsFixed(2) ?? '0.00'}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                size: 16,
                                                color: isExpiringSoon
                                                    ? Colors.orange
                                                    : Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Expires: ${med['expiryDate'] != null ? med['expiryDate'].toString().split('T')[0] : 'N/A'}',
                                              style: TextStyle(
                                                color: isExpiringSoon
                                                    ? Colors.orange
                                                    : Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          med['manufacturer'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (isLowStock)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              'LOW STOCK',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        else if (isExpiringSoon)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              'EXPIRING',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddMedicine,
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.addNewMedicine),
      ),
    );
  }

  bool _isExpiringSoon(String? expiryDate) {
    if (expiryDate == null) return false;
    final expiry = DateTime.tryParse(expiryDate);
    if (expiry == null) return false;
    final now = DateTime.now();
    final threeMonthsFromNow = now.add(const Duration(days: 90));
    return expiry.isBefore(threeMonthsFromNow);
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'pain relief':
        return Colors.red.shade400;
      case 'antibiotic':
        return Colors.blue.shade400;
      case 'vitamin':
        return Colors.green.shade400;
      case 'diabetes':
        return Colors.purple.shade400;
      case 'cardiovascular':
        return Colors.orange.shade400;
      case 'gastrointestinal':
        return Colors.teal.shade400;
      default:
        return AppTheme.primaryTeal;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'pain relief':
        return Icons.healing;
      case 'antibiotic':
        return Icons.medical_services;
      case 'vitamin':
        return Icons.local_pharmacy;
      case 'diabetes':
        return Icons.bloodtype;
      case 'cardiovascular':
        return Icons.favorite;
      case 'gastrointestinal':
        return Icons.health_and_safety;
      default:
        return Icons.medication;
    }
  }
}
