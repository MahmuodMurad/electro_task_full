import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../widgets/app_text_field.dart';
import '../../../../widgets/app_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message.tr()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App icon
                      Icon(
                        Icons.person_add_rounded,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'register'.tr(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Name field
                      AppTextField(
                        controller: _nameController,
                        label: 'name'.tr(),
                        prefixIcon: Icons.person_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'field_required'.tr();
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email field
                      AppTextField(
                        controller: _emailController,
                        label: 'email'.tr(),
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'field_required'.tr();
                          if (!value.contains('@')) return 'invalid_email'.tr();
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      AppTextField(
                        controller: _passwordController,
                        label: 'password'.tr(),
                        obscureText: true,
                        prefixIcon: Icons.lock_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'field_required'.tr();
                          if (value.length < 6) return 'field_required'.tr();
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Register button
                      AppButton(
                        label: 'register'.tr(),
                        isLoading: state is AuthLoading,
                        onPressed: _onRegister,
                      ),
                      const SizedBox(height: 16),

                      // Login link
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text('already_have_account'.tr()),
                      ),
                    ],
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
