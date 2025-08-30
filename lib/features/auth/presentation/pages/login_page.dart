import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import 'otp_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _mobileFocusNode = FocusNode();
  
  @override
  void dispose() {
    _mobileController.dispose();
    _mobileFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpSentSuccessfully) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OtpVerificationPage(
                  mobileNumber: _mobileController.text,
                ),
              ),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Title
                  Column(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Icon(
                          Icons.shopping_cart,
                          size: 60,
                          color: AppColors.surface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Beena Mart',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Welcome to your shopping destination',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Mobile Number Input
                  CustomTextField(
                    controller: _mobileController,
                    labelText: 'Mobile Number',
                    hintText: 'Enter your 10-digit mobile number',
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your mobile number';
                      }
                      if (value.length != 10) {
                        return 'Please enter a valid 10-digit mobile number';
                      }
                      return null;
                    },
                    focusNode: _mobileFocusNode,
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Send OTP Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Send OTP',
                        onPressed: state is AuthLoading ? null : _sendOtp,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Terms and Conditions
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(SendOtpRequested(_mobileController.text));
    }
  }
}
