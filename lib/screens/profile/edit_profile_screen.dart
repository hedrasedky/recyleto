import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recyleto_app/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../utils/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _isImageLoading = false;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Load from AuthProvider first (cached data)
      _nameController.text = authProvider.pharmacyName ?? '';
      _emailController.text = authProvider.userEmail ?? '';

      // Try to get fresh data from API
      final profileData = await _apiService.getUserProfile();
      if (profileData.containsKey('data')) {
        final profile = profileData['data']['profile'] ?? profileData['data'];
        _nameController.text =
            profile['pharmacyName'] ?? profile['businessName'] ?? '';
        _emailController.text =
            profile['email'] ?? profile['businessEmail'] ?? '';
        _phoneController.text =
            profile['businessPhone'] ?? profile['phone'] ?? '';
        _addressController.text =
            profile['businessAddress']?['street'] ?? profile['address'] ?? '';
      }
    } catch (e) {
      // Fallback to AuthProvider data if API fails
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _nameController.text = authProvider.pharmacyName ?? '';
      _emailController.text = authProvider.userEmail ?? '';
      _phoneController.text = '';
      _addressController.text = '';
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _isImageLoading = true;
        });

        final File imageFile = File(image.path);

        // Upload image to API
        await _apiService.uploadProfileImage(image.path);

        setState(() {
          _selectedImageFile = imageFile;
          _isImageLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.profilePictureUpdated),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImageLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)!.failedToUpdateProfilePicture),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare profile data
      final profileData = {
        'pharmacyName': _nameController.text.trim(),
        'businessEmail': _emailController.text.trim(),
        'businessPhone': _phoneController.text.trim(),
        'mobileNumber':
            _phoneController.text.trim(), // Same as businessPhone for now
        'businessAddress': {
          'street': _addressController.text.trim(),
        },
      };

      // Update profile via API
      await _apiService.updateUserProfile(profileData);

      // Update AuthProvider with new data
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.refreshUserProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.profileUpdatedSuccessfully),
            backgroundColor: AppTheme.successGreen,
          ),
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToUpdateProfile),
            backgroundColor: AppTheme.errorRed,
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.nameIsRequired;
    }
    if (value.length < 2) {
      return AppLocalizations.of(context)!.nameMustBeAtLeast2Characters;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.emailIsRequired;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppLocalizations.of(context)!.pleaseEnterValidEmail;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.phoneNumberIsRequired;
    }
    if (!RegExp(r'^\+?[\d\s-]+$').hasMatch(value)) {
      return AppLocalizations.of(context)!.pleaseEnterValidPhoneNumber;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editProfile),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    AppLocalizations.of(context)!.save,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Picture Section
              _buildProfilePictureSection(theme),

              const SizedBox(height: 32),

              // Personal Information
              _buildPersonalInfoSection(theme),

              const SizedBox(height: 24),

              // Contact Information
              _buildContactInfoSection(theme),

              const SizedBox(height: 24),

              // Save Button
              CustomButton(
                text: AppLocalizations.of(context)!.save,
                isLoading: _isLoading,
                onPressed: _isLoading ? null : _saveProfile,
                width: double.infinity,
                height: 56,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryGreen,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _selectedImageFile != null
                      ? Image.file(
                          _selectedImageFile!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        )
                      : Container(
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                ),
              ),
              if (_isImageLoading)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.background,
                      width: 3,
                    ),
                  ),
                  child: IconButton(
                    onPressed: _isImageLoading ? null : _pickImage,
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.tapToChangeProfilePicture,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(ThemeData theme) {
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
              Icon(
                Icons.person,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.personalInformation,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            labelText: AppLocalizations.of(context)!.fullName,
            hintText: AppLocalizations.of(context)!.enterYourFullName,
            controller: _nameController,
            validator: _validateName,
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            labelText: AppLocalizations.of(context)!.emailAddress,
            hintText: AppLocalizations.of(context)!.enterYourEmailAddress,
            controller: _emailController,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection(ThemeData theme) {
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
              Icon(
                Icons.contact_phone,
                color: AppTheme.primaryGreen,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.contactInformation,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            labelText: AppLocalizations.of(context)!.phoneNumber,
            hintText: AppLocalizations.of(context)!.enterYourPhoneNumber,
            controller: _phoneController,
            validator: _validatePhone,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            labelText: AppLocalizations.of(context)!.address,
            hintText: AppLocalizations.of(context)!.enterYourAddress,
            controller: _addressController,
            maxLines: 3,
            prefixIcon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }
}
