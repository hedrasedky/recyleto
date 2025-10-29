import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _genericNameController = TextEditingController();
  final _packSizeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ApiService _apiService = ApiService();

  String? _selectedCategory;
  String? _selectedForm;
  DateTime _selectedExpiryDate = DateTime.now().add(const Duration(days: 365));
  bool _isOTC = true;
  bool _isLoading = false;

  List<String> get _diseaseCategories => [
        AppLocalizations.of(context)!.painRelief,
        AppLocalizations.of(context)!.antibiotics,
        AppLocalizations.of(context)!.diabetes,
        AppLocalizations.of(context)!.heartDisease,
        AppLocalizations.of(context)!.respiratory,
        AppLocalizations.of(context)!.gastrointestinal,
        AppLocalizations.of(context)!.neurological,
        AppLocalizations.of(context)!.dermatological,
        AppLocalizations.of(context)!.ophthalmology,
        AppLocalizations.of(context)!.urology,
        AppLocalizations.of(context)!.gynecology,
        AppLocalizations.of(context)!.pediatrics,
        AppLocalizations.of(context)!.oncology,
        AppLocalizations.of(context)!.psychiatry,
        AppLocalizations.of(context)!.endocrinology,
        AppLocalizations.of(context)!.rheumatology,
        AppLocalizations.of(context)!.immunology,
        AppLocalizations.of(context)!.infectiousDiseases,
        AppLocalizations.of(context)!.emergencyMedicine,
        AppLocalizations.of(context)!.other,
      ];

  List<String> get _medicineForms => [
        'Tablet',
        'Capsule',
        'Syrup',
        'Injection',
        'Cream',
        'Ointment',
        'Drops',
        'Powder',
        'Patch',
        'Suppository',
        'Inhaler',
        'Gel',
        'Lotion',
        'Spray',
        'Solution',
      ];

  @override
  void dispose() {
    _medicineNameController.dispose();
    _genericNameController.dispose();
    _packSizeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _manufacturerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)), // 10 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.primaryTeal,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedExpiryDate) {
      setState(() {
        _selectedExpiryDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.addMedicineToRecyleto,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearForm,
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context)!.resetForm,
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
                    Icons.add_box,
                    size: 48,
                    color: AppTheme.primaryTeal,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.addNewMedicineToPlatform,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.fillDetailsMakeAvailable,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkGray.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
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
                    // Basic Information
                    _buildSectionHeader(
                        AppLocalizations.of(context)!.basicInformation,
                        Icons.info_outline),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _medicineNameController,
                      label: AppLocalizations.of(context)!.medicineName,
                      hint: AppLocalizations.of(context)!.medicineNameExample,
                      icon: Icons.medication,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseEnterMedicineName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _genericNameController,
                      label: AppLocalizations.of(context)!.genericName,
                      hint: AppLocalizations.of(context)!.genericNameExample,
                      icon: Icons.science,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseEnterGenericName;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),

                    _buildFormDropdown(),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _packSizeController,
                      label: AppLocalizations.of(context)!.packSize + ' *',
                      hint: AppLocalizations.of(context)!.packSizeExample,
                      icon: Icons.inventory_2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .pleaseEnterPackSize;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Pricing & Inventory
                    _buildSectionHeader(
                        AppLocalizations.of(context)!.pricingInventory,
                        Icons.attach_money),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _quantityController,
                            label:
                                AppLocalizations.of(context)!.quantity + ' *',
                            hint: '0',
                            icon: Icons.numbers,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!
                                    .enterQuantity;
                              }
                              if (int.tryParse(value) == null ||
                                  int.parse(value) <= 0) {
                                return AppLocalizations.of(context)!
                                    .enterValidQuantity;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _priceController,
                            label:
                                AppLocalizations.of(context)!.price + ' (\$) *',
                            hint: '0.00',
                            icon: Icons.attach_money,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppLocalizations.of(context)!.enterPrice;
                              }
                              if (double.tryParse(value) == null ||
                                  double.parse(value) <= 0) {
                                return AppLocalizations.of(context)!
                                    .enterValidPrice;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildExpiryDateSelector(),
                    const SizedBox(height: 24),

                    // Manufacturer Details
                    _buildSectionHeader(
                        AppLocalizations.of(context)!.manufacturerDetails,
                        Icons.business),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _manufacturerController,
                      label: AppLocalizations.of(context)!.manufacturer,
                      hint: AppLocalizations.of(context)!.manufacturerExample,
                      icon: Icons.business,
                    ),
                    const SizedBox(height: 16),

                    const SizedBox(height: 24),

                    // Additional Information
                    _buildSectionHeader(
                        AppLocalizations.of(context)!.additionalInformation,
                        Icons.notes),
                    const SizedBox(height: 16),

                    _buildOTCSelector(),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _descriptionController,
                      label: AppLocalizations.of(context)!.description,
                      hint: AppLocalizations.of(context)!.descriptionExample,
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryTeal,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTeal,
              ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryTeal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.category + ' *',
        prefixIcon: const Icon(Icons.category, color: AppTheme.primaryTeal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
        ),
      ),
      items: _diseaseCategories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 20,
                color: AppTheme.primaryTeal,
              ),
              const SizedBox(width: 8),
              Text(category),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  Widget _buildFormDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedForm,
      decoration: InputDecoration(
        labelText: 'Medicine Form *',
        prefixIcon: const Icon(Icons.medication, color: AppTheme.primaryTeal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 2),
        ),
      ),
      items: _medicineForms.map((form) {
        return DropdownMenuItem(
          value: form,
          child: Row(
            children: [
              Icon(
                _getFormIcon(form),
                size: 20,
                color: AppTheme.primaryTeal,
              ),
              const SizedBox(width: 8),
              Text(form),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedForm = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select medicine form';
        }
        return null;
      },
    );
  }

  Widget _buildExpiryDateSelector() {
    return InkWell(
      onTap: _selectExpiryDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.primaryTeal),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.expiryDate + ' *',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedExpiryDate.day.toString().padLeft(2, '0')}/${_selectedExpiryDate.month.toString().padLeft(2, '0')}/${_selectedExpiryDate.year}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildOTCSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.medicineType,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  value: true,
                  groupValue: _isOTC,
                  onChanged: (value) {
                    setState(() {
                      _isOTC = value!;
                    });
                  },
                  title: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppTheme.successGreen),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.otc),
                    ],
                  ),
                  subtitle: Text(AppLocalizations.of(context)!.overTheCounter),
                  activeColor: AppTheme.primaryTeal,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  value: false,
                  groupValue: _isOTC,
                  onChanged: (value) {
                    setState(() {
                      _isOTC = value!;
                    });
                  },
                  title: Row(
                    children: [
                      const Icon(Icons.warning, color: AppTheme.errorRed),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.rx),
                    ],
                  ),
                  subtitle:
                      Text(AppLocalizations.of(context)!.prescriptionRequired),
                  activeColor: AppTheme.primaryTeal,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('💊 Add Medicine Screen: Starting to save medicine...');
      await _apiService.initialize();

      // Normalize form to allowed backend values
      final allowedForms = {
        'Tablet',
        'Capsule',
        'Syrup',
        'Injection',
        'Ointment',
        'Cream',
        'Drops',
        'Inhaler',
        'Other'
      };
      final selectedForm = _selectedForm ?? 'Tablet';
      final normalizedForm =
          allowedForms.contains(selectedForm) ? selectedForm : 'Other';

      // Prepare medicine data for API (all required fields)
      final medicineData = {
        'name': _medicineNameController.text.trim(),
        'genericName': _genericNameController.text.trim(),
        'form': normalizedForm, // Ensure backend-allowed form
        'packSize': _packSizeController.text.trim(),
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'expiryDate': _selectedExpiryDate.toIso8601String(),
        'manufacturer': _manufacturerController.text.trim(),
        'batchNumber':
            'BATCH${DateTime.now().millisecondsSinceEpoch}', // Generate batch number
        'category': _selectedCategory ?? 'Other', // Add category field
        'requiresPrescription': 'false', // Default to false (OTC)
      };

      print('💊 Add Medicine Screen: Medicine data prepared: $medicineData');
      print(
          '💊 Add Medicine Screen: Selected form: $_selectedForm → normalized: $normalizedForm');
      print('💊 Add Medicine Screen: About to call API...');

      // Call API to add medicine
      final result = await _apiService.addMedicine(medicineData);
      print('💊 Add Medicine Screen: API call successful! Result: $result');

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.medicineRequestSent,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear form and return success to trigger refresh in inventory
        _clearForm();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('❌ Add Medicine Error: ${e.toString()}');
      if (mounted) {
        // Show error message with details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to add medicine: ${e.toString()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.retry,
              textColor: Colors.white,
              onPressed: _saveMedicine,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _medicineNameController.clear();
    _genericNameController.clear();
    _packSizeController.clear();
    _quantityController.clear();
    _priceController.clear();
    _manufacturerController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedExpiryDate = DateTime.now().add(const Duration(days: 365));
      _isOTC = true;
    });
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
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryTeal,
                side: const BorderSide(color: AppTheme.primaryTeal),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveMedicine,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.addToRecyleto,
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

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'pain relief':
      case 'مسكنات الألم':
        return Icons.healing;
      case 'antibiotics':
      case 'مضادات حيوية':
        return Icons.biotech;
      case 'diabetes':
      case 'أدوية السكري':
        return Icons.favorite;
      case 'heart disease':
      case 'أمراض القلب':
        return Icons.favorite_border;
      case 'respiratory':
      case 'أمراض الجهاز التنفسي':
        return Icons.air;
      case 'gastrointestinal':
      case 'أمراض الجهاز الهضمي':
        return Icons.restaurant;
      case 'neurological':
      case 'أمراض عصبية':
        return Icons.psychology;
      case 'dermatological':
      case 'أمراض جلدية':
        return Icons.face;
      case 'ophthalmology':
      case 'أمراض العيون':
        return Icons.visibility;
      case 'urology':
      case 'أمراض المسالك البولية':
        return Icons.water_drop;
      case 'gynecology':
      case 'أمراض نسائية':
        return Icons.pregnant_woman;
      case 'pediatrics':
      case 'أدوية الأطفال':
        return Icons.child_care;
      case 'oncology':
      case 'أدوية السرطان':
        return Icons.science;
      case 'psychiatry':
      case 'أدوية نفسية':
        return Icons.psychology;
      case 'endocrinology':
      case 'أمراض الغدد الصماء':
        return Icons.biotech;
      case 'rheumatology':
      case 'أمراض الروماتيزم':
        return Icons.accessibility;
      case 'immunology':
      case 'أمراض المناعة':
        return Icons.shield;
      case 'infectious diseases':
      case 'أمراض معدية':
        return Icons.bug_report;
      case 'emergency medicine':
      case 'أدوية الطوارئ':
        return Icons.emergency;
      default:
        return Icons.medication;
    }
  }

  IconData _getFormIcon(String form) {
    switch (form.toLowerCase()) {
      case 'tablet':
        return Icons.medication;
      case 'capsule':
        return Icons.circle;
      case 'syrup':
        return Icons.local_drink;
      case 'injection':
        return Icons.vaccines;
      case 'cream':
        return Icons.face;
      case 'ointment':
        return Icons.healing;
      case 'drops':
        return Icons.water_drop;
      case 'powder':
        return Icons.grain;
      case 'patch':
        return Icons.medical_services;
      case 'suppository':
        return Icons.medication_liquid;
      case 'inhaler':
        return Icons.air;
      case 'gel':
        return Icons.opacity;
      case 'lotion':
        return Icons.water;
      case 'spray':
        return Icons.air;
      case 'solution':
        return Icons.science;
      default:
        return Icons.medication;
    }
  }
}
