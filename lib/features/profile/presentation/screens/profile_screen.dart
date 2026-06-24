import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager_electro/core/theme/app_colors.dart';
import 'package:task_manager_electro/core/theme/theme_cubit.dart';
import 'package:task_manager_electro/core/theme/theme_state.dart';
import 'package:task_manager_electro/core/locale/locale_cubit.dart';
import 'package:task_manager_electro/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:task_manager_electro/features/auth/presentation/cubit/auth_state.dart';
import 'package:task_manager_electro/widgets/fade_in_slide.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'profile'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state is AuthAuthenticated ? state.user : null;
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              // User info card
              FadeInSlide(
                duration: const Duration(milliseconds: 400),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                        child: Text(
                          (user?.name ?? '?')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        user?.name ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textDark : AppColors.textLight,
                        ),
                      ),
                      subtitle: Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Settings Header
              FadeInSlide(
                duration: const Duration(milliseconds: 450),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: Text(
                    'settings'.tr(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                    ),
                  ),
                ),
              ),

              // Dark mode toggle card
              FadeInSlide(
                duration: const Duration(milliseconds: 500),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: BlocBuilder<ThemeCubit, ThemeState>(
                    builder: (context, themeState) {
                      return SwitchListTile(
                        secondary: const Icon(Icons.dark_mode_outlined),
                        title: Text(
                          'dark_mode'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        activeThumbColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                        value: themeState.themeMode == ThemeMode.dark,
                        onChanged: (_) => context.read<ThemeCubit>().toggleTheme(),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Language selector card
              FadeInSlide(
                duration: const Duration(milliseconds: 550),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.language_outlined),
                    title: Text(
                      'language'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: DropdownButton<String>(
                      value: context.locale.languageCode,
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(12),
                      style: TextStyle(
                        color: isDark ? AppColors.textDark : AppColors.textLight,
                        fontWeight: FontWeight.bold,
                      ),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'ar', child: Text('العربية')),
                      ],
                      onChanged: (code) {
                        if (code != null) {
                          context.read<LocaleCubit>().changeLocale(context, code);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Logout button
              FadeInSlide(
                duration: const Duration(milliseconds: 600),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(
                    'logout'.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => context.read<AuthCubit>().logout(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
