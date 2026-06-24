import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:task_manager_electro/core/theme/app_colors.dart';
import 'package:task_manager_electro/widgets/fade_in_slide.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../widgets/app_text_field.dart';
import '../../../../widgets/app_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF1E1E38), AppColors.bgDark]
                    : [const Color(0xFFEEF2FF), AppColors.bgLight],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo Section
                        FadeInSlide(
                          duration: const Duration(milliseconds: 400),
                          child: Icon(
                            Icons.task_alt_rounded,
                            size: 90,
                            color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FadeInSlide(
                          duration: const Duration(milliseconds: 500),
                          child: Text(
                            'app_name'.tr(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: isDark ? AppColors.textDark : AppColors.textLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeInSlide(
                          duration: const Duration(milliseconds: 550),
                          child: Text(
                            'login'.tr(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Form Fields Card Container
                        FadeInSlide(
                          duration: const Duration(milliseconds: 600),
                          child: Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  AppTextField(
                                    controller: _emailController,
                                    label: 'email'.tr(),
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icons.email_outlined,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) return 'field_required'.tr();
                                      if (!value.contains('@')) return 'invalid_email'.tr();
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  AppTextField(
                                    controller: _passwordController,
                                    label: 'password'.tr(),
                                    obscureText: true,
                                    prefixIcon: Icons.lock_outlined,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) return 'field_required'.tr();
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login button
                        FadeInSlide(
                          duration: const Duration(milliseconds: 650),
                          child: AppButton(
                            label: 'login'.tr(),
                            isLoading: state is AuthLoading,
                            onPressed: _onLogin,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Register link
                        FadeInSlide(
                          duration: const Duration(milliseconds: 700),
                          child: TextButton(
                            onPressed: () => context.go('/register'),
                            child: Text(
                              'dont_have_account'.tr(),
                              style: TextStyle(
                                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
