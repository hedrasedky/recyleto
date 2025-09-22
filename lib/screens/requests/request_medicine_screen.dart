import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class RequestMedicineScreen extends StatefulWidget {
  const RequestMedicineScreen({super.key});

  @override
  State<RequestMedicineScreen> createState() => _RequestMedicineScreenState();
}

class _RequestMedicineScreenState extends State<RequestMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _genericNameController = TextEditingController();
  final _packSizeController = TextEditingController();
  final _notesController = TextEditingController();
  final ApiService _apiService = ApiService();

  String _selectedForm = 'Tablet';
  String _selectedUrgency = 'medium';
  File? _selectedImage;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  final List<String> _forms = [
    'Tablet',
    'Syrup',
    'Capsule',
    'Injection',
    'Ointment',
    'Drops',
    'Inhaler',
    'Other',
  ];

  final List<Map<String, dynamic>> _urgencyLevels = [
    {
      'value': 'low',
      'label': 'Low Priority',
      'description': 'Can wait 3-7 days',
      'color': AppTheme.successGreen,
      'icon': Icons.schedule,
    },
    {
      'value': 'medium',
      'label': 'Medium Priority',
      'description': 'Needed within 1-3 days',
      'color': AppTheme.warningOrange,
      'icon': Icons.warning_amber,
    },
    {
      'value': 'high',
      'label': 'High Priority',
      'description': 'Needed within 24 hours',
      'color': AppTheme.errorRed,
      'icon': Icons.priority_high,
    },
    {
      'value': 'urgent',
      'label': 'Urgent',
      'description': 'Needed immediately',
      'color': AppTheme.errorRed,
      'icon': Icons.emergency,
    },
  ];

  @override
  void dispose() {
    _medicineNameController.dispose();
    _genericNameController.dispose();
    _packSizeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.camera_alt, color: AppTheme.primaryTeal),
              title: Text(AppLocalizations.of(context)!.takePhoto),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 800,
                  maxHeight: 800,
                  imageQuality: 80,
                );
                if (photo != null) {
                  setState(() {
                    _selectedImage = File(photo.path);
                  });
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppTheme.primaryTeal),
              title: Text(AppLocalizations.of(context)!.chooseFromGallery),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 800,
                  maxHeight: 800,
                  imageQuality: 80,
                );
                if (photo != null) {
                  setState(() {
                    _selectedImage = File(photo.path);
                  });
                }
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.errorRed),
                title: Text(AppLocalizations.of(context)!.removeImage),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.requestMedicine,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.warningOrange,
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
              color: AppTheme.warningOrange.withOpacity(0.1),
              child: Column(
                children: [
                  const Icon(
                    Icons.add_shopping_cart,
                    size: 48,
                    color: AppTheme.warningOrange,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.requestUnavailableMedicine,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warningOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!
                        .requestUnavailableMedicineDescription,
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
                    // Image Upload Section
                    _buildImageUploadSection(),
                    const SizedBox(height: 24),

                    // Medicine Details
                    _buildSectionHeader(
                        AppLocalizations.of(context)!.medicineDetails,
                        Icons.medication),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _medicineNameController,
                      label: AppLocalizations.of(context)!.medicineName,
                      hint: AppLocalizations.of(context)!.medicineNameHint,
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
                      hint: AppLocalizations.of(context)!.genericNameHint,
                      icon: Icons.science,
                    ),
                    const SizedBox(height: 16),

                    _buildFormDropdown(),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _packSizeController,
                      label: AppLocalizations.of(context)!.packSize,
                      hint: AppLocalizations.of(context)!.packSizeHint,
                      icon: Icons.inventory_2,
                    ),
                    const SizedBox(height: 24),

                    // Urgency Level
                    _buildSectionHeader(
                        AppLocalizations.of(context)!.requestPriority,
                        Icons.priority_high),
                    const SizedBox(height: 16),
                    _buildUrgencySelector(),
                    const SizedBox(height: 24),

                    // Additional Notes
                    _buildSectionHeader(
                        AppLocalizations.of(context)!.additionalInformation,
                        Icons.notes),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _notesController,
                      label: AppLocalizations.of(context)!.additionalNotes,
                      hint: AppLocalizations.of(context)!.additionalNotesHint,
                      icon: Icons.description,
                      maxLines: 4,
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

  Widget _buildImageUploadSection() {
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
              const Icon(
                Icons.camera_alt,
                color: AppTheme.warningOrange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.medicineImage,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warningOrange,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.uploadMedicineImageDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          if (_selectedImage != null)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.noImageSelected,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(
                    _selectedImage != null ? Icons.edit : Icons.camera_alt,
                    size: 20,
                  ),
                  label: Text(_selectedImage != null
                      ? AppLocalizations.of(context)!.changeImage
                      : AppLocalizations.of(context)!.addImage),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.warningOrange,
                    side: const BorderSide(color: AppTheme.warningOrange),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_selectedImage != null) ...[
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  icon: const Icon(Icons.delete, size: 20),
                  label: Text(AppLocalizations.of(context)!.remove),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.warningOrange,
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.warningOrange,
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
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.warningOrange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.warningOrange, width: 2),
        ),
      ),
    );
  }

  Widget _buildFormDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedForm,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.form,
        prefixIcon: const Icon(Icons.category, color: AppTheme.warningOrange),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.warningOrange, width: 2),
        ),
      ),
      items: _forms.map((form) {
        return DropdownMenuItem(
          value: form,
          child: Row(
            children: [
              Icon(
                _getFormIcon(form),
                size: 20,
                color: AppTheme.warningOrange,
              ),
              const SizedBox(width: 8),
              Text(_getFormDisplayName(form)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedForm = value!;
        });
      },
    );
  }

  Widget _buildUrgencySelector() {
    return Column(
      children: _urgencyLevels.map((urgency) {
        final isSelected = _selectedUrgency == urgency['value'];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? urgency['color'] : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? urgency['color'].withOpacity(0.1)
                : Colors.transparent,
          ),
          child: RadioListTile<String>(
            value: urgency['value'],
            groupValue: _selectedUrgency,
            onChanged: (value) {
              setState(() {
                _selectedUrgency = value!;
              });
            },
            title: Row(
              children: [
                Icon(
                  urgency['icon'],
                  color: urgency['color'],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getUrgencyDisplayName(urgency['value']),
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            subtitle: Text(
              _getUrgencyDescription(urgency['value']),
              style: TextStyle(
                color: isSelected ? urgency['color'] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            activeColor: urgency['color'],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _apiService.initialize();

      // Get pharmacy ID from AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final pharmacyId = authProvider.userProfile?['id'] ?? 'unknown_pharmacy';

      // Prepare request data for API
      final requestData = {
        'medicineName': _medicineNameController.text.trim(),
        'genericName': _genericNameController.text.trim(),
        'form': _selectedForm,
        'packSize': _packSizeController.text.trim(),
        'urgency': _selectedUrgency.toLowerCase(),
        'notes': _notesController.text.trim(),
        'status': 'pending',
        'imageUrl': _selectedImage?.path, // Send file path directly
        'requestedAt': DateTime.now().toIso8601String(),
        'pharmacyId': pharmacyId,
      };

      // Call API to create medicine request
      await _apiService.createMedicineRequest(requestData);

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
                    'Request for "${_medicineNameController.text}" submitted successfully!',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 3),
          ),
        );

        // Clear form and navigate back
        _clearForm();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Failed to submit request: ${e.toString()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _submitRequest,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearForm() {
    _medicineNameController.clear();
    _genericNameController.clear();
    _packSizeController.clear();
    _notesController.clear();
    setState(() {
      _selectedForm = 'Tablet';
      _selectedUrgency = 'medium';
      _selectedImage = null;
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
                foregroundColor: AppTheme.warningOrange,
                side: const BorderSide(color: AppTheme.warningOrange),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warningOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)!.submitRequest,
                      style: const TextStyle(
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

  String _getFormDisplayName(String form) {
    switch (form) {
      case 'Tablet':
        return AppLocalizations.of(context)!.tablet;
      case 'Capsule':
        return AppLocalizations.of(context)!.capsule;
      case 'Syrup':
        return AppLocalizations.of(context)!.syrup;
      case 'Injection':
        return AppLocalizations.of(context)!.injection;
      case 'Cream':
        return AppLocalizations.of(context)!.cream;
      case 'Ointment':
        return AppLocalizations.of(context)!.ointment;
      case 'Drops':
        return AppLocalizations.of(context)!.drops;
      case 'Inhaler':
        return AppLocalizations.of(context)!.inhaler;
      case 'Patch':
        return AppLocalizations.of(context)!.patch;
      case 'Powder':
        return AppLocalizations.of(context)!.powder;
      case 'Other':
        return AppLocalizations.of(context)!.other;
      default:
        return form;
    }
  }

  String _getUrgencyDisplayName(String urgency) {
    switch (urgency) {
      case 'low':
        return AppLocalizations.of(context)!.lowPriority;
      case 'medium':
        return AppLocalizations.of(context)!.mediumPriority;
      case 'high':
        return AppLocalizations.of(context)!.highPriority;
      case 'urgent':
        return AppLocalizations.of(context)!.urgent;
      default:
        return urgency;
    }
  }

  String _getUrgencyDescription(String urgency) {
    switch (urgency) {
      case 'low':
        return AppLocalizations.of(context)!.lowPriorityDescription;
      case 'medium':
        return AppLocalizations.of(context)!.mediumPriorityDescription;
      case 'high':
        return AppLocalizations.of(context)!.highPriorityDescription;
      case 'urgent':
        return AppLocalizations.of(context)!.urgentDescription;
      default:
        return urgency;
    }
  }
}
