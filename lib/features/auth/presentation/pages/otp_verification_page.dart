import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../../domain/entities/check_user_response.dart';
import 'home_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String mobileNumber;
  
  const OtpVerificationPage({
    super.key,
    required this.mobileNumber,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _otpFocusNode = FocusNode();
  final _nameFocusNode = FocusNode();
  final _addressFocusNode = FocusNode();
  
  bool _showNameField = false;
  bool _isLoading = false;
  CheckUserResponse? _userData;

  @override
  void initState() {
    super.initState();
    _checkUserExists();
  }
  
  @override
  void dispose() {
    _otpController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _otpFocusNode.dispose();
    _nameFocusNode.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkUserExists() async {
    setState(() => _isLoading = true);
    
    context.read<AuthBloc>().add(CheckUserExistsRequested(widget.mobileNumber));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is CheckUserExistsSuccess) {
            setState(() {
              _userData = state.userData;
              _showNameField = !state.userData.exists; // Show fields for new users
              _isLoading = false;
            });
            
            // Pre-fill name and address for existing users
            if (state.userData.exists && state.userData.user != null) {
              _nameController.text = state.userData.user!.name;
              _addressController.text = state.userData.user!.address ?? '';
            }
          } else if (state is CheckUserExistsFailure) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AuthSuccess) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Icon(
                                Icons.verified,
                                color: AppColors.surface,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Verify OTP',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter the 6-digit code sent to\n${widget.mobileNumber}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Show user info for existing users
                        if (_userData?.exists == true && _userData?.user != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Welcome back!',
                                      style: AppTextStyles.h3.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Name: ${_userData!.user!.name}',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                if (_userData!.user!.address != null)
                                  Text(
                                    'Address: ${_userData!.user!.address}',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                              ],
                            ),
                          ),
                        
                        // Show registration notice for new users
                        if (_showNameField)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.person_add, color: AppColors.warning),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'New User Registration - Please provide your details',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        // OTP Input
                        CustomTextField(
                          controller: _otpController,
                          focusNode: _otpFocusNode,
                          labelText: 'OTP Code',
                          hintText: 'Enter 6-digit OTP',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter OTP';
                            }
                            if (value.length != 6) {
                              return 'OTP must be 6 digits';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Name Input (for new users)
                        if (_showNameField) ...[
                          CustomTextField(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            labelText: 'Full Name *',
                            hintText: 'Enter your full name',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              if (value.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Address Input (for new users)
                          CustomTextField(
                            controller: _addressController,
                            focusNode: _addressFocusNode,
                            labelText: 'Address *',
                            hintText: 'Enter your complete address',
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your address';
                              }
                              if (value.trim().length < 10) {
                                return 'Address must be at least 10 characters';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                        ],
                        
                        // Verify Button
                        CustomButton(
                          onPressed: _verifyOtp,
                          text: _showNameField ? 'Complete Registration' : 'Verify OTP',
                          isLoading: false,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Resend OTP
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive the code? ",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: _resendOtp,
                              child: Text(
                                'Resend OTP',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Back to Login
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Back to Login',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }
  
  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      final otp = _otpController.text;
      
      // For new users, name and address are always required
      final name = _showNameField ? _nameController.text.trim() : null;
      final address = _showNameField ? _addressController.text.trim() : null;
      
      // Additional validation for new users
      if (_showNameField) {
        if (name == null || name.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter your name'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
        
        if (address == null || address.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter your address'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }
      
      context.read<AuthBloc>().add(
        VerifyOtpRequested(
          mobileNumber: widget.mobileNumber,
          otp: otp,
          name: name,
          address: address,
        ),
      );
    }
  }
  
  void _resendOtp() {
    context.read<AuthBloc>().add(SendOtpRequested(widget.mobileNumber));
  }
}
