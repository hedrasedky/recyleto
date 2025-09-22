import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

import '../../services/mock_data_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final MockDataService _mockDataService = MockDataService();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _deliveries = [];
  bool _isLoading = false;
  String? _error;

  // Search and filter
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedDateRange = 'All';

  // Add delivery form

  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _orderItemsController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedDeliveryType = 'standard';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final List<String> _deliveryTypes = ['standard', 'express', 'same_day'];

  final List<String> _statuses = [
    'All',
    'pending',
    'confirmed',
    'in_transit',
    'delivered',
    'cancelled'
  ];

  final List<String> _dateRanges = [
    'All',
    'Today',
    'This Week',
    'This Month',
    'Last 7 Days',
    'Last 30 Days'
  ];

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerAddressController.dispose();
    _orderItemsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveries() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      _deliveries = await _mockDataService.getDeliveries();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredDeliveries {
    return _deliveries.where((delivery) {
      final matchesSearch = delivery['customerName']
                  ?.toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ==
              true ||
          delivery['orderId']
                  ?.toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ==
              true;

      final matchesStatus =
          _selectedStatus == 'All' || delivery['status'] == _selectedStatus;

      final matchesDateRange = _matchesDateRange(delivery['createdAt']);

      return matchesSearch && matchesStatus && matchesDateRange;
    }).toList();
  }

  bool _matchesDateRange(String? createdAt) {
    if (_selectedDateRange == 'All') return true;
    if (createdAt == null) return false;

    final createdDate = DateTime.tryParse(createdAt);
    if (createdDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_selectedDateRange) {
      case 'Today':
        return createdDate.isAfter(today);
      case 'This Week':
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        return createdDate.isAfter(weekStart);
      case 'This Month':
        final monthStart = DateTime(now.year, now.month, 1);
        return createdDate.isAfter(monthStart);
      case 'Last 7 Days':
        final sevenDaysAgo = today.subtract(const Duration(days: 7));
        return createdDate.isAfter(sevenDaysAgo);
      case 'Last 30 Days':
        final thirtyDaysAgo = today.subtract(const Duration(days: 30));
        return createdDate.isAfter(thirtyDaysAgo);
      default:
        return true;
    }
  }

  void _showAddDeliveryDialog() {
    _resetForm();
    _showDeliveryDialog();
  }

  void _showDeliveryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.createNewDelivery),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: _customerNameController,
                  labelText: AppLocalizations.of(context)!.customerName,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.customerNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _customerPhoneController,
                  labelText: AppLocalizations.of(context)!.customerPhone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .customerPhoneRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _customerAddressController,
                  labelText: AppLocalizations.of(context)!.deliveryAddress,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!
                          .deliveryAddressRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _orderItemsController,
                  labelText: AppLocalizations.of(context)!.orderItems,
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.orderItemsRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Delivery Type Selection
                DropdownButtonFormField<String>(
                  value: _selectedDeliveryType,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.deliveryType,
                    border: OutlineInputBorder(),
                  ),
                  items: _deliveryTypes.map((type) {
                    String displayText;
                    switch (type) {
                      case 'standard':
                        displayText =
                            AppLocalizations.of(context)!.standardDelivery;
                        break;
                      case 'express':
                        displayText =
                            AppLocalizations.of(context)!.expressDelivery;
                        break;
                      case 'same_day':
                        displayText =
                            AppLocalizations.of(context)!.sameDayDelivery;
                        break;
                      default:
                        displayText = type;
                    }
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(displayText),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDeliveryType = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Delivery type is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Date and Time Selection
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(AppLocalizations.of(context)!.deliveryDate),
                        subtitle: Text(
                          DateFormat('MMM dd, yyyy').format(_selectedDate),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(AppLocalizations.of(context)!.deliveryTime),
                        subtitle: Text(_selectedTime.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () => _selectTime(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  controller: _notesController,
                  labelText: 'Notes (Optional)',
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetForm();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          CustomButton(
            onPressed: _createDelivery,
            text: AppLocalizations.of(context)!.createDelivery,
            backgroundColor: AppTheme.primaryTeal,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createDelivery() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final deliveryData = {
        'customerName': _customerNameController.text.trim(),
        'customerPhone': _customerPhoneController.text.trim(),
        'customerAddress': _customerAddressController.text.trim(),
        'orderItems': _orderItemsController.text.trim(),
        'deliveryType': _selectedDeliveryType,
        'deliveryDate': _selectedDate.toIso8601String(),
        'deliveryTime':
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        'notes': _notesController.text.trim(),
        'status': 'pending',
      };

      await _mockDataService.addDelivery(deliveryData);

      if (mounted) {
        Navigator.of(context).pop();
        _resetForm();
        _loadDeliveries();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.deliveryCreatedSuccessfully),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context)!.failedToCreateDelivery}: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _updateDeliveryStatus(
      String deliveryId, String currentStatus) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.updateDeliveryStatus),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                '${AppLocalizations.of(context)!.currentStatus}: ${_getStatusDisplayName(currentStatus)}'),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.selectNewStatus),
            const SizedBox(height: 8),
            ...(_statuses
                .where((status) => status != 'All' && status != currentStatus)
                .map(
                  (status) => ListTile(
                    title: Text(_getStatusDisplayName(status)),
                    onTap: () => Navigator.of(context).pop(status),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );

    if (newStatus != null) {
      try {
        await _mockDataService.updateDeliveryStatus(deliveryId, newStatus);
        _loadDeliveries();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Delivery status updated to ${_getStatusDisplayName(newStatus)}'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.failedToUpdateDeliveryStatus}: ${e.toString()}'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'pending':
        return AppLocalizations.of(context)!.pending;
      case 'confirmed':
        return AppLocalizations.of(context)!.confirmed;
      case 'in_transit':
        return AppLocalizations.of(context)!.inTransit;
      case 'delivered':
        return AppLocalizations.of(context)!.delivered;
      case 'cancelled':
        return AppLocalizations.of(context)!.cancelled;
      default:
        return status;
    }
  }

  String _getDateRangeDisplayName(String range) {
    switch (range) {
      case 'All':
        return AppLocalizations.of(context)!.all;
      case 'Today':
        return AppLocalizations.of(context)!.today;
      case 'This Week':
        return AppLocalizations.of(context)!.thisWeek;
      case 'This Month':
        return AppLocalizations.of(context)!.thisMonth;
      case 'Last 7 Days':
        return AppLocalizations.of(context)!.last7Days;
      case 'Last 30 Days':
        return AppLocalizations.of(context)!.last30Days;
      default:
        return range;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warningOrange;
      case 'confirmed':
        return AppTheme.primaryTeal;
      case 'in_transit':
        return AppTheme.darkTeal;
      case 'delivered':
        return AppTheme.successGreen;
      case 'cancelled':
        return AppTheme.errorRed;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'in_transit':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _resetForm() {
    _customerNameController.clear();
    _customerPhoneController.clear();
    _customerAddressController.clear();
    _orderItemsController.clear();
    _notesController.clear();
    _selectedDeliveryType = 'standard';
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.deliveryManagement),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadDeliveries,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          _buildSearchAndFilters(),

          // Deliveries List
          Expanded(
            child: _buildDeliveriesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDeliveryDialog,
        backgroundColor: AppTheme.primaryTeal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          CustomTextField(
            controller: TextEditingController(text: _searchQuery),
            labelText: 'Search deliveries...',
            prefixIcon: Icons.search,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.status,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _statuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status == 'All'
                          ? AppLocalizations.of(context)!.allStatuses
                          : _getStatusDisplayName(status)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedDateRange,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.dateRange,
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _dateRanges.map((range) {
                    return DropdownMenuItem<String>(
                      value: range,
                      child: Text(_getDateRangeDisplayName(range)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDateRange = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveriesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_filteredDeliveries.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDeliveries.length,
      itemBuilder: (context, index) {
        final delivery = _filteredDeliveries[index];
        return _buildDeliveryCard(delivery);
      },
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    final status = delivery['status'] ?? 'pending';
    final deliveryDate = delivery['scheduledDate'];
    final deliveryTime = delivery['scheduledTime'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status).withOpacity(0.1),
          child: Icon(
            _getStatusIcon(status),
            color: _getStatusColor(status),
          ),
        ),
        title: Text(
          delivery['customerName'] ?? 'Unknown Customer',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${AppLocalizations.of(context)!.order}: ${delivery['orderId'] ?? 'N/A'}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusDisplayName(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (deliveryDate != null)
                  Text(
                    DateFormat('MMM dd').format(DateTime.parse(deliveryDate)),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'status') {
              _updateDeliveryStatus(delivery['id'], status);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'status',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.updateStatus),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                    'Customer Phone', delivery['customerPhone'] ?? 'N/A'),
                _buildDetailRow(
                    'Delivery Address', delivery['deliveryAddress'] ?? 'N/A'),
                _buildDetailRow(
                    'Order Items', _formatOrderItems(delivery['orderItems'])),
                _buildDetailRow(
                    'Delivery Type', delivery['deliveryType'] ?? 'N/A'),
                if (deliveryDate != null)
                  _buildDetailRow(
                      'Scheduled Date',
                      DateFormat('MMM dd, yyyy')
                          .format(DateTime.parse(deliveryDate))),
                if (deliveryTime != null)
                  _buildDetailRow('Scheduled Time', deliveryTime),
                if (delivery['notes']?.isNotEmpty == true)
                  _buildDetailRow('Notes', delivery['notes']),
                _buildDetailRow(
                    'Created',
                    delivery['createdAt'] != null
                        ? DateFormat('MMM dd, yyyy HH:mm')
                            .format(DateTime.parse(delivery['createdAt']))
                        : 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatOrderItems(dynamic orderItems) {
    if (orderItems == null) return 'N/A';

    if (orderItems is List) {
      if (orderItems.isEmpty) return 'No items';

      return orderItems.map((item) {
        if (item is Map<String, dynamic>) {
          final name = item['name'] ?? 'Unknown Item';
          final quantity = item['quantity'] ?? 0;
          final price = item['price'] ?? 0.0;
          return '$name (Qty: $quantity, \$${price.toStringAsFixed(2)})';
        }
        return item.toString();
      }).join('\n');
    }

    return orderItems.toString();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorRed.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load deliveries',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: _loadDeliveries,
            text: 'Retry',
            backgroundColor: AppTheme.primaryTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 64,
            color: Colors.grey.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'No deliveries found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }
}
