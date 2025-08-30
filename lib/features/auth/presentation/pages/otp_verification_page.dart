import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
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
  
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
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
          if (state is AuthSuccess) {
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
        child: SafeArea(
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
                          size: 40,
                          color: AppColors.surface,
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
                  
                  // OTP Input
                  CustomTextField(
                    controller: _otpController,
                    labelText: 'OTP',
                    hintText: 'Enter 6-digit OTP',
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the OTP';
                      }
                      if (value.length != 6) {
                        return 'Please enter a valid 6-digit OTP';
                      }
                      return null;
                    },
                    focusNode: _otpFocusNode,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // New User Registration Notice
                  if (_showNameField) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New User Registration',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Please provide your name and address to complete registration',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Name Input (for new users)
                  if (_showNameField) ...[
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name *',
                      hintText: 'Enter your full name',
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                      focusNode: _nameFocusNode,
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _addressController,
                      labelText: 'Address *',
                      hintText: 'Enter your complete address',
                      keyboardType: TextInputType.streetAddress,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your address';
                        }
                        if (value.trim().length < 10) {
                          return 'Please enter a complete address';
                        }
                        return null;
                      },
                      focusNode: _addressFocusNode,
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Verify OTP Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      String buttonText;
                      if (_showNameField) {
                        buttonText = 'Complete Registration';
                      } else {
                        buttonText = 'Verify OTP';
                      }
                      
                      return CustomButton(
                        text: buttonText,
                        onPressed: state is AuthLoading ? null : _verifyOtp,
                        isLoading: state is AuthLoading,
                      );
                    },
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
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return TextButton(
                            onPressed: state is AuthLoading ? null : _resendOtp,
                            child: Text(
                              'Resend OTP',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
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
  
  Future<void> _checkUserStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedMobile = prefs.getString(AppConstants.mobileNumberKey);
      final cachedUser = prefs.getString(AppConstants.userKey);
      
      // Check if we have cached data for this mobile number
      if (cachedMobile == widget.mobileNumber && cachedUser != null) {
        // Existing user - no name/address fields needed
        setState(() {
          _showNameField = false;
        });
      } else {
        // New user - force name and address fields
        setState(() {
          _showNameField = true;
        });
      }
    } catch (e) {
      // If any error, assume new user for safety
      setState(() {
        _showNameField = true;
      });
    }
  }
  
  void _resendOtp() {
    context.read<AuthBloc>().add(SendOtpRequested(widget.mobileNumber));
  }
  

}
