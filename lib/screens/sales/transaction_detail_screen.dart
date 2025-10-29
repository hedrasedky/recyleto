import 'package:flutter/material.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _transaction;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  Future<void> _loadTransactionDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await _apiService.initialize();

      // Get transaction ID from the passed transaction
      final transactionId = widget.transaction['_id'] ??
          widget.transaction['transactionId'] ??
          widget.transaction['id'];

      if (transactionId == null) {
        throw Exception('Transaction ID not found');
      }

      // Load detailed transaction from API
      final transactions = await _apiService.getTransactions();
      final detailedTransaction = transactions.firstWhere(
        (tx) =>
            tx['_id'] == transactionId ||
            tx['transactionId'] == transactionId ||
            tx['id'] == transactionId,
        orElse: () => widget.transaction, // Fallback to passed transaction
      );

      setState(() {
        _transaction = detailedTransaction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _transaction = widget.transaction; // Fallback to passed transaction
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> get _transactionData =>
      _transaction ?? widget.transaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.transaction),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.transaction),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading transaction details',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadTransactionDetails,
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
            '${AppLocalizations.of(context)!.transaction} #${_transactionData['transactionId'] ?? _transactionData['transactionReference'] ?? _transactionData['id'] ?? 'Unknown'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(theme),

            const SizedBox(height: 16),

            // Customer Information
            _buildCustomerInfo(theme),

            const SizedBox(height: 16),

            // Order Items
            _buildOrderItems(theme),

            const SizedBox(height: 16),

            // Payment Summary
            _buildPaymentSummary(theme),

            const SizedBox(height: 16),

            // Transaction Notes
            if ((_transactionData['notes'] != null &&
                    _transactionData['notes'].toString().isNotEmpty) ||
                (_transactionData['description'] != null &&
                    _transactionData['description'].toString().isNotEmpty))
              _buildTransactionNotes(theme),

            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    Color statusColor;
    IconData statusIcon;

    switch (_transactionData['status']) {
      case 'completed':
        statusColor = AppTheme.successGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = AppTheme.warningOrange;
        statusIcon = Icons.pending;
        break;
      case 'refunded':
        statusColor = AppTheme.errorRed;
        statusIcon = Icons.undo;
        break;
      default:
        statusColor = AppTheme.primaryTeal;
        statusIcon = Icons.receipt;
    }

    final transactionDate = DateTime.parse(
        _transactionData['createdAt'] ?? DateTime.now().toIso8601String());
    final formattedDate =
        '${transactionDate.year}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}';
    final formattedTime =
        '${transactionDate.hour.toString().padLeft(2, '0')}:${transactionDate.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (_transactionData['status'] ?? 'pending')
                      .toString()
                      .toUpperCase(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order placed on $formattedDate at $formattedTime',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(ThemeData theme) {
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
          Row(
            children: [
              const Icon(
                Icons.person,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.customerInformation,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
              AppLocalizations.of(context)!.name,
              _transactionData['customerInfo']?['name'] ??
                  _transactionData['customerName'] ??
                  AppLocalizations.of(context)!.anonymous,
              theme),
          if ((_transactionData['customerInfo']?['phone'] != null &&
                  _transactionData['customerInfo']!['phone']
                      .toString()
                      .isNotEmpty) ||
              (_transactionData['customerPhone'] != null &&
                  _transactionData['customerPhone'].toString().isNotEmpty))
            _buildInfoRow(
                AppLocalizations.of(context)!.phone,
                _transactionData['customerInfo']?['phone'] ??
                    _transactionData['customerPhone'].toString(),
                theme),
        ],
      ),
    );
  }

  Widget _buildOrderItems(ThemeData theme) {
    final items = _transactionData['items'] ?? [];

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
          Row(
            children: [
              const Icon(
                Icons.shopping_bag,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${AppLocalizations.of(context)!.orderItems} (${items.length})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              AppLocalizations.of(context)!.noItemsFound,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...items
                .map<Widget>((item) => _buildOrderItem(item, theme))
                .toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item, ThemeData theme) {
    final quantity = item['quantity'] ?? 1;
    final price = item['unitPrice'] ?? item['price'] ?? 0.0;
    final total = item['totalPrice'] ?? item['lineTotal'] ?? (quantity * price);

    // Handle medicine details from API
    String medicineName = 'Unknown Item';
    if (item['medicineId'] is Map) {
      // If medicineId is populated with medicine details
      medicineName = item['medicineId']['name'] ??
          item['medicineId']['medicineName'] ??
          'Unknown Item';
    } else if (item['name'] != null) {
      // Fallback to name field
      medicineName = item['name'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.medication,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicineName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppLocalizations.of(context)!.qty}: $quantity × \$${price.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                // Add generic name if available
                if (item['medicineId'] is Map &&
                    item['medicineId']['genericName'] != null)
                  Text(
                    item['medicineId']['genericName'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(ThemeData theme) {
    final subtotal = _transactionData['subtotal'] ?? 0.0;
    final tax = _transactionData['tax'] ?? 0.0;
    final total =
        _transactionData['totalAmount'] ?? _transactionData['total'] ?? 0.0;
    final paymentMethod = _transactionData['paymentMethod'] ?? 'Cash';

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
          Row(
            children: [
              const Icon(
                Icons.payment,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.paymentSummary,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(AppLocalizations.of(context)!.subtotal,
              '\$${subtotal.toStringAsFixed(2)}', theme),
          _buildSummaryRow(AppLocalizations.of(context)!.tax5Percent,
              '\$${tax.toStringAsFixed(2)}', theme),
          const Divider(height: 24),
          _buildSummaryRow(
            AppLocalizations.of(context)!.total,
            '\$${total.toStringAsFixed(2)}',
            theme,
            isTotal: true,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(AppLocalizations.of(context)!.paymentMethod,
              paymentMethod, theme),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to support chat
                  },
                  icon: const Icon(Icons.support_agent),
                  label: Text(AppLocalizations.of(context)!.getHelp),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    side: const BorderSide(color: AppTheme.primaryGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to refund screen
                  },
                  icon: const Icon(Icons.undo),
                  label: Text(AppLocalizations.of(context)!.requestRefund),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? AppTheme.primaryGreen : null,
            ),
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
          Row(
            children: [
              const Icon(
                Icons.notes,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.transactionNotes,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _transactionData['notes']?.toString() ??
                _transactionData['description']?.toString() ??
                '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
