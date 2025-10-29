import 'package:flutter/material.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class ExpiringMedicinesScreen extends StatefulWidget {
  const ExpiringMedicinesScreen({super.key});

  @override
  State<ExpiringMedicinesScreen> createState() =>
      _ExpiringMedicinesScreenState();
}

class _ExpiringMedicinesScreenState extends State<ExpiringMedicinesScreen> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _expiringMedicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpiringMedicines();
  }

  Future<void> _loadExpiringMedicines() async {
    try {
      final medicines = await _apiService.getExpiringMedicines();

      // Debug: Print medicine data to see what we're getting
      print('🔍 Expiring Medicines Data:');
      for (int i = 0; i < medicines.length; i++) {
        final medicine = medicines[i];
        print('🔍 Medicine $i:');
        print('  - Name: ${medicine['name']}');
        print('  - Manufacturer: ${medicine['manufacturer']}');
        print('  - Category: ${medicine['category']}');
        print('  - Transaction Number: ${medicine['transactionNumber']}');
        print('  - Last Transaction Date: ${medicine['lastTransactionDate']}');
        print('  - Created At: ${medicine['createdAt']}');
        print('  - Full data: $medicine');
        print('---');
      }

      setState(() {
        _expiringMedicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading medicines: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.expiringMedicinesTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.errorRed,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadExpiringMedicines,
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.refresh,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _expiringMedicines.isEmpty
              ? _buildEmptyState()
              : _buildMedicinesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppTheme.successGreen.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noExpiringMedicines,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successGreen,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.allMedicinesAreFresh,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGray.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesList() {
    return Column(
      children: [
        // Header Info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppTheme.errorRed.withOpacity(0.1),
          child: Column(
            children: [
              const Icon(
                Icons.schedule,
                size: 48,
                color: AppTheme.errorRed,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.expiringMedicinesDescription,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.errorRed,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${_expiringMedicines.length} ${AppLocalizations.of(context)!.items}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkGray.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ),

        // Medicines List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _expiringMedicines.length,
            itemBuilder: (context, index) {
              final medicine = _expiringMedicines[index];
              return _buildMedicineCard(medicine);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    final expiryDate = DateTime.tryParse(medicine['expiryDate'] ?? '');
    final daysUntilExpiry =
        expiryDate != null ? expiryDate.difference(DateTime.now()).inDays : 0;

    Color urgencyColor;
    IconData urgencyIcon;
    String urgencyText;

    if (daysUntilExpiry <= 7) {
      urgencyColor = AppTheme.errorRed;
      urgencyIcon = Icons.emergency;
      urgencyText = AppLocalizations.of(context)!.critical;
    } else if (daysUntilExpiry <= 30) {
      urgencyColor = Colors.orange;
      urgencyIcon = Icons.warning;
      urgencyText = AppLocalizations.of(context)!.high;
    } else {
      urgencyColor = AppTheme.warningOrange;
      urgencyIcon = Icons.schedule;
      urgencyText = AppLocalizations.of(context)!.medium;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: urgencyColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: urgencyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: urgencyColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine['name'] ??
                            AppLocalizations.of(context)!.unknownMedicine,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        medicine['genericName'] ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.darkGray.withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: urgencyColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        urgencyIcon,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        urgencyText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Details Grid
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    AppLocalizations.of(context)!.expiryDate,
                    expiryDate != null
                        ? '${expiryDate.day}/${expiryDate.month}/${expiryDate.year}'
                        : 'Unknown',
                    Icons.calendar_today,
                    urgencyColor,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    AppLocalizations.of(context)!.daysUntilExpiry,
                    daysUntilExpiry > 0
                        ? '$daysUntilExpiry days'
                        : AppLocalizations.of(context)!.expired,
                    Icons.timer,
                    urgencyColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    AppLocalizations.of(context)!.manufacturer,
                    medicine['manufacturer'] ??
                        AppLocalizations.of(context)!.unknown,
                    Icons.business,
                    AppTheme.darkGray,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    AppLocalizations.of(context)!.category,
                    medicine['category'] ??
                        AppLocalizations.of(context)!.unknown,
                    Icons.category,
                    AppTheme.darkGray,
                  ),
                ),
              ],
            ),

            // Transaction and Purchase Info
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    AppLocalizations.of(context)!.transactionNumber,
                    medicine['transactionNumber'] ??
                        AppLocalizations.of(context)!.unknown,
                    Icons.receipt,
                    AppTheme.primaryTeal,
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    AppLocalizations.of(context)!.purchaseDate,
                    medicine['lastTransactionDate'] != null
                        ? '${DateTime.parse(medicine['lastTransactionDate']).day}/${DateTime.parse(medicine['lastTransactionDate']).month}/${DateTime.parse(medicine['lastTransactionDate']).year}'
                        : medicine['createdAt'] != null
                            ? '${DateTime.parse(medicine['createdAt']).day}/${DateTime.parse(medicine['createdAt']).month}/${DateTime.parse(medicine['createdAt']).year}'
                            : AppLocalizations.of(context)!.unknown,
                    Icons.shopping_cart,
                    AppTheme.successGreen,
                  ),
                ),
              ],
            ),

            if (medicine['batchNumber'] != null) ...[
              const SizedBox(height: 12),
              _buildDetailItem(
                AppLocalizations.of(context)!.batchNumber,
                medicine['batchNumber'],
                Icons.inventory,
                AppTheme.darkGray,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
      String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: color.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkGray.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
