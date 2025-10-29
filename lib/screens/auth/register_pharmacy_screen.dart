import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterPharmacyScreen extends StatefulWidget {
  const RegisterPharmacyScreen({super.key});

  @override
  State<RegisterPharmacyScreen> createState() => _RegisterPharmacyScreenState();
}

class _RegisterPharmacyScreenState extends State<RegisterPharmacyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pharmacyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  dynamic _licenseImageFile; // Can be File or XFile

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _loadSavedData();
  }

  void _checkAuthStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  Future<void> _loadSavedData() async {
    // Load saved form data if available
    // This helps preserve user input in case of errors
    try {
      // You can implement SharedPreferences here to save/load form data
      print('🔍 Loading saved form data...');
    } catch (e) {
      print('❌ Error loading saved data: $e');
    }
  }

  Future<void> _saveFormData() async {
    // Save form data to prevent loss on errors
    try {
      final formData = {
        'pharmacyName': _pharmacyNameController.text,
        'businessEmail': _emailController.text,
        'businessPhone': _phoneController.text,
        'mobileNumber': _mobileController.text,
        'street': _streetController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zipCode': _zipCodeController.text,
      };
      print('🔍 Saving form data: $formData');
      // You can implement SharedPreferences here to save form data
    } catch (e) {
      print('❌ Error saving form data: $e');
    }
  }

  @override
  void dispose() {
    _pharmacyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _registerPharmacy() async {
    if (!_formKey.currentState!.validate()) return;
    if (_licenseImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.registerPharmacy),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    // Add confirmation before registration
    final shouldProceed = await _showConfirmationDialog();
    if (!shouldProceed) return;

    setState(() => _isLoading = true);
    try {
      // Save form data before registration attempt
      await _saveFormData();

      // Prepare pharmacy data
      final pharmacyData = {
        'pharmacyName': _pharmacyNameController.text.trim(),
        'businessEmail': _emailController.text.trim(),
        'businessPhone': _phoneController.text.trim(),
        'mobileNumber': _mobileController.text.trim(),
        'password': _passwordController.text,
        'confirmPassword': _confirmPasswordController.text,
        'businessAddress': {
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'zipCode': _zipCodeController.text.trim(),
        },
        'licenseImage':
            _licenseImageFile, // The AuthProvider will handle file upload
      };

      // Use AuthProvider for registration
      await context.read<AuthProvider>().registerPharmacy(pharmacyData);

      if (mounted) {
        _showSuccessMessage();
        // Small delay before navigation
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Don't clear form data on error - preserve user input
        _showErrorMessage(
            'An error occurred during registration: ${e.toString()}');
        print('Registration error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickLicenseImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        setState(() {
          if (kIsWeb) {
            // For web, store XFile directly
            _licenseImageFile = image;
          } else {
            // For mobile, convert to File
            _licenseImageFile = File(image.path);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select image: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Widget _buildImageWidget() {
    if (_licenseImageFile == null) return const SizedBox.shrink();

    if (kIsWeb) {
      final xFile = _licenseImageFile as XFile;
      return FutureBuilder<Uint8List>(
        future: xFile.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            );
          } else if (snapshot.hasError) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.image,
                size: 40,
                color: Colors.grey,
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    } else {
      final file = _licenseImageFile as File;
      return Image.file(
        file,
        fit: BoxFit.cover,
      );
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.local_pharmacy,
                    color: AppTheme.primaryTeal,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text('Confirm Registration'),
                ],
              ),
              content: Text(
                'Do you want to register the pharmacy:\n${_pharmacyNameController.text.trim()}?\n\nData will be sent to the system.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.darkGray),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.registerPharmacy,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.retry,
          textColor: Colors.white,
          onPressed: () => _registerPharmacy(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.registerPharmacy),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryTeal.withOpacity(0.1),
              AppTheme.lightGray,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryTeal, AppTheme.darkTeal],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryTeal.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_pharmacy,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.registerPharmacy,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.registerPharmacy,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.darkGray.withOpacity(0.7),
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pharmacy Name
                  CustomTextField(
                    controller: _pharmacyNameController,
                    labelText: AppLocalizations.of(context)!.registerPharmacy,
                    hintText: AppLocalizations.of(context)!.registerPharmacy,
                    prefixIcon: Icons.business,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter pharmacy name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Email
                  CustomTextField(
                    controller: _emailController,
                    labelText: AppLocalizations.of(context)!.email,
                    hintText: AppLocalizations.of(context)!.enterYourEmail,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Phone Numbers
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _phoneController,
                          labelText: 'Business Phone',
                          hintText: 'Business phone',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter business phone';
                            }
                            final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
                            if (!phoneRegex.hasMatch(value.trim())) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _mobileController,
                          labelText: 'Mobile Number',
                          hintText: 'Mobile number',
                          prefixIcon: Icons.mobile_friendly,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter mobile number';
                            }
                            final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
                            if (!phoneRegex.hasMatch(value.trim())) {
                              return 'Please enter a valid mobile number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Address
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _streetController,
                          labelText: 'Street',
                          hintText: 'Street name',
                          prefixIcon: Icons.location_on_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter street';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _cityController,
                          labelText: 'City',
                          hintText: 'City name',
                          prefixIcon: Icons.location_city,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter city';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _stateController,
                          labelText: 'State',
                          hintText: 'State name',
                          prefixIcon: Icons.map,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter state';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _zipCodeController,
                          labelText: 'ZIP Code',
                          hintText: 'ZIP code',
                          prefixIcon: Icons.numbers,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter ZIP code';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // License Upload
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pharmacy License',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.darkGray,
                                ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickLicenseImage,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: _licenseImageFile != null
                              ? Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: AppTheme.primaryTeal
                                            .withOpacity(0.1),
                                      ),
                                      child: _buildImageWidget(),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryTeal,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload_outlined,
                                      size: 40,
                                      color: AppTheme.darkGray.withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Upload License Image',
                                      style: TextStyle(
                                        color:
                                            AppTheme.darkGray.withOpacity(0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Password
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'Enter password',
                    prefixIcon: Icons.lock_outlined,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.darkGray.withOpacity(0.5),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
                      final hasLower = RegExp(r'[a-z]').hasMatch(value);
                      final hasDigit = RegExp(r'[0-9]').hasMatch(value);
                      if (!(hasUpper && hasLower && hasDigit)) {
                        return 'Use upper, lower letters and numbers';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Confirm Password
                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: AppLocalizations.of(context)!.password,
                    hintText: AppLocalizations.of(context)!.enterYourPassword,
                    prefixIcon: Icons.lock_outlined,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.darkGray.withOpacity(0.5),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // Register Button
                  CustomButton(
                    onPressed: _isLoading ? null : _registerPharmacy,
                    text: _isLoading
                        ? AppLocalizations.of(context)!.signingIn
                        : AppLocalizations.of(context)!.registerPharmacy,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 24),

                  // Terms and Privacy
                  Text(
                    'By registering, you agree to our Terms of Service and Privacy Policy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.darkGray.withOpacity(0.6),
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
